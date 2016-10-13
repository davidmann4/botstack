require 'mechanize'
require 'spintax_parser'

class String
  include SpintaxParser
end

class BaseBotLogic

  def self.send_message(msg, recipient, options={})
    options.merge({recipient: recipient})
    reply_message(msg, options)
  end

  def self.reply_message(msg, options={})

    options = {
      resolve_emoji: true,
      spintax: true,
      recipient: @fb_params.sender
    }.merge(options)

    if @request_type == "TEXT" or @request_type == "CALLBACK"

      if(options[:resolve_emoji])
        msg = compute_emojis(msg)
      end

      if(options[:spintax])
        msg = msg.unspin
      end

      Bot.deliver(
        recipient: options[:recipient],
        message: {
          text: msg
        }
      )
    end
  end

  def self.reply_image(img_url)
    if @request_type == "TEXT" or @request_type == "CALLBACK"
      Bot.deliver(
        recipient: @fb_params.sender,
        message: {
          attachment: {
            type: 'image',
            payload: {
              url: img_url
            }
          }
        }
      )
    end
  end

  def self.reply_quick_reply(msg, options)
    options ||= %W(Yes No)
    if @request_type == "TEXT" or @request_type == "CALLBACK"
      Bot.deliver(
        recipient: @fb_params.sender,
        message: {
          text: msg,
          quick_replies: options.map { |option| {content_type: 'text', title: option, payload: "QUICK_#{option.upcase}"} }
        }
      )
    end
  end

  def self.reply_html(html)
    if @request_type == "TEXT" or @request_type == "CALLBACK"
      kit = IMGKit.new("<meta charset='UTF-8'/>"+html, :quality => 100, :width => 300)    
      kit.stylesheets << 'public/search_result.css'

      file = kit.to_file('public/html_response.jpg')
      reply_image(ENV["DOMAIN_NAME"] + "/html_response.jpg")
    end
  end

  #TODO: maje it useful
  def self.reply_button
    if @request_type == "TEXT" or @request_type == "CALLBACK"

      buttons = Messenger::Templates::Buttons.new(
        text: 'Some Cool Text',
        buttons: [
          Messenger::Elements::Button.new(
            type: 'web_url',
            title: 'Show Website',
            value: 'https://petersapparel.parseapp.com'
          ),
          Messenger::Elements::Button.new(
            type: 'web_url',
            title: 'Show Website',
            value: 'https://petersapparel.parseapp.com'
          )
        ]
      )

      Messenger::Client.send(
        Messenger::Request.new(
          buttons,
          @fb_params.first_entry.sender_id
        )
      )
   end
  end

  #TODO: maje it useful
  def self.reply_bubble
    if @request_type == "TEXT" or @request_type == "CALLBACK"

        bubble1 = Messenger::Elements::Bubble.new(
          title: 'Bubble 1',
          subtitle: 'Cool Bubble',
          #item_url: 'http://lorempixel.com/400/400/cats',
          image_url: 'http://lorempixel.com/400/400/cats',
          buttons: [
            Messenger::Elements::Button.new(
              type: 'postback',
              title: 'Show Website',
              value: 'TEST'
            )
          ]
        )

        #lets create Generic template
        generic = Messenger::Templates::Generic.new(
          elements: [bubble1,bubble1,bubble1,bubble1,bubble1]
        )

        #now send Generic template to the user
        Messenger::Client.send(
          Messenger::Request.new(generic, @fb_params.first_entry.sender_id)
        )
   end
  end

  def self.get_message
    if @request_type == "TEXT"
      @fb_params.text
    else
      nil
    end
  end

  def self.handle_user

    #binding.pry 
    user_id = @fb_params.sender["id"].to_i
    user = User.find_by_fb_id user_id

    if user.nil?
      user = User.new 
      user.fb_id = user_id
      user.state_machine = 0
      user.last_message_received = Time.now
    end

    if @request_type == "TEXT" or @request_type == "CALLBACK"

      # reset statemachine if longer ago than 5 minutes
      if Time.now - user.last_message_received > (60 * 5)
        @current_user = user
        state_reset
      end

      user.last_message_received = Time.now
    end

    user.save!
    user
  end

  def self.handle_request(fb_params, type="TEXT")

    @fb_params = fb_params
    @request_type = type
    @current_user = handle_user

    @state_handled = false    
    
    #handle different attachments the user could send
    if type == "TEXT"   
      if !fb_params.messaging["message"]["attachments"].nil?
        attachment_type = fb_params.messaging["message"]["attachments"][0]["type"] #so wrong lol

        if attachment_type == "location"
          @request_type = "LOCATION"
          @fb_params = fb_params.messaging["message"]["attachments"][0]["payload"]
        elsif attachment_type == "image"
          @request_type = "IMAGE"
          @fb_params = fb_params.messaging["message"]["attachments"][0]["payload"]
        elsif attachment_type == "audio"
          @request_type = "AUDIO"
          @fb_params = fb_params.messaging["message"]["attachments"][0]["payload"]  
        elsif attachment_type == "fallback"
          @request_type = "ATTACHMENT_UNKNOWN"
          @fb_params = fb_params.messaging["message"]["attachments"][0]["payload"]
        else
          puts "UNKNOWN ATTACHMENT: "  + attachment_type        
        end
      end
    end

    bot_logic
    

    #rescue Exception => e
    #  puts e
  end



  ## websearch MODULE

  def self.search_request_on_website(options)
    options = {
      form_name: 'searchform',
      result_css_selector: 'li.search-list-item > a',
      image_css_selector: 'img',
      button_text: 'more infos'
    }.merge(options)
    
    if @request_type == "TEXT"
      a = Mechanize.new { |agent|
        agent.user_agent_alias = 'Mac Safari'
      }

      a.get(options[:url]) do |page|
        search_result = page.form_with(:name => options[:form_name]) do |search|
          search.suche = get_message
        end.submit

        search_results_bubbles = []

        search_result.search(options[:result_css_selector]).each  do |link|
          img = link.css(options[:image_css_selector]).first

          if !img.nil? && img["srcset"].starts_with?("http") && search_results_bubbles.size < 8
            bubble = {
              title: link.css(".search-list-item-title").text,
              subtitle: link["title"],
              #item_url: 'http://lorempixel.com/400/400/cats',
              image_url: img["srcset"],
              buttons: [
                {
                  type: 'postback',
                  title: options[:button_text],
                  payload: 'search_result_' + link["href"]
                }
              ]
            }     

            search_results_bubbles.push(bubble)   
          end
        end

        generic = {
          "template_type": "generic",
          "elements": search_results_bubbles
        }

        Bot.deliver(
          recipient: @fb_params.sender,
          message: {
            attachment: {
              type: 'template',
              payload: generic
            }
          }
        )

      end
    end
  end

  def self.handle_search_result(options={}) 
    options = {
      result_css_selector: '.result'
    }.merge(options)

    if @request_type == "CALLBACK"
      search_url = options[:url] + @fb_params.payload
      search_url['search_result_'] = ''
      puts search_url

      a = Mechanize.new { |agent|
        agent.user_agent_alias = 'Mac Safari'
      }

      a.get(search_url) do |page|
        results = page.search(options[:result_css_selector]).first

        reply_html(results.to_html)
      end
    end
  end

  ## EMOJI MODULE

  def self.get_emoji(name)
    Emoji.find_by_alias(name).raw
  end

  def self.reply_emoji(name)
    reply_message get_emoji(name)
  end

  def self.compute_emojis(content)
    EmojiParser.detokenize(content)
  end

  def self.parse_emojis(content)
    EmojiParser.tokenize()
  end

  ## State Machine Module
  def self.state_action(required_state, action)
    if @request_type == "TEXT" or @request_type == "CALLBACK"
      if @state_handled == false and @current_user.state_machine == required_state 
        self.send(action)
        @state_handled = true
      end
    end
  end

  def self.state_go(state=-1)
    if state == -1
      @current_user.state_machine = @current_user.state_machine + 1
    else
      @current_user.state_machine = state
    end

    puts "going state: " + @current_user.state_machine.to_s

    @current_user.save!
  end

  def self.state_reset
    state_go Settings.state_machine_reset_to
  end

  ## Broadcast Module
  
  def self.handle_blacklist
    if get_message == "stop"
      blacklist = Blacklist.new 
      blacklist.user_id = @current_user.id
      blacklist.status = true
    end
  end

  def self.broadcast_all(msg)
    User.all.each do |user|
      send_message(msg, user.fb_id)
    end
  end

  def self.subscribe_user(campaign_name)
    subscription = Subscription.new 
    subscription.user_id = @current_user.id
    subscription.campaign_name = campaign_name

    subscription.save!
  end

  def self.broadcast_list(campaign_name, msg)
    users = Subscription.where campaign_name: campaign_name

    users.each do |user|
      send_message(msg, user.fb_id)
    end
  end

  def self.last_step_for_user(user_id)
    notification = Notification.where user_id: user_id, :order => "ssid"
    notification.first
  end
   #--> self.offer_subscription
   #--> self.handle_subscription_response

  ## User Roulette Module
   #--> self.roulette_message
   #--> self.handle_roulette_messege_response

  ## Browser Module
   #--> self.
   #--> self.

  ## CSV Lookup Module
   #--> Google Spreadsheet Lookup Module

  ## Question Module
   #--> self.ask_questions
   #--> self.compute_answer


  ## Setup Module

  def self.set_welcome_message(message)
    Facebook::Messenger::Thread.set(
      setting_type: 'greeting',
      greeting: {
        text: message
      }
    )
  end

  def self.set_get_started_button(callback_name)
      Facebook::Messenger::Thread.set(
        setting_type: 'call_to_actions',
        thread_state: 'new_thread',
        call_to_actions: [
          {
            payload: callback_name
          }
        ]
      )
  end

  def self.set_bot_menu(options)
    options ||= %W(Reset)
    Facebook::Messenger::Thread.set(
      setting_type: 'call_to_actions',
      thread_state: 'existing_thread',
      call_to_actions: options.map { |option| {type: 'postback', title: option, payload: "#{option.upcase}_BOT"} }
    )
  end

end