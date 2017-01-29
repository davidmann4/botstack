require 'mechanize'
require 'spintax_parser'
require 'openssl'

class String
  include SpintaxParser
end

class BaseBotLogic

  def self.get_profile(user_id)
    response = HTTParty.get("https://graph.facebook.com/v2.6/#{user_id}?fields=first_name,last_name,profile_pic,locale,timezone,gender&access_token=#{Settings.page_access_token}")
    JSON.parse(response.body)
  end

  def self.bot_logic
    reply_message "NOT IMPLEMENTED"
  end

  def self.get_fb_params
    @fb_params
  end

  def self.get_request_type
    @request_type
  end

  def self.get_current_user
    @current_user
  end

  def self.get_msg_meta
    @msg_meta
  end

  def self.get_state_handled
    @state_handled
  end

  def self.send_message(msg, recipient, options={})
    options.merge({recipient: recipient})
    reply_message(msg, options)
  end

  def self.reply_message(msg, options={})
    options = {
      resolve_emoji: true,
      spintax: true,
      recipient: {id: @current_user.fb_id}
    }.merge(options)

    if @request_type == "TEXT" or @request_type == "CALLBACK"  or @request_type == "LOCATION"

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
        recipient: {id: @current_user.fb_id},
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

  def self.reply_quick_buttons(msg, options)
    options ||= %W(Yes No)
    if @request_type == "TEXT" or @request_type == "CALLBACK" or @request_type == "LOCATION"
      Bot.deliver(
        recipient: {id: @current_user.fb_id},
        message: {
          text: msg,
          quick_replies: options.map { |option| {content_type: 'text', title: option, payload: "QUICK_#{option.upcase}"} }
        }
      )
    end
  end

  def self.reply_location_button(msg)
    if @request_type == "TEXT" or @request_type == "CALLBACK"
      Bot.deliver(
        recipient: {id: @current_user.fb_id},
        message:{
          "text": msg,
          "quick_replies":[
            {
              "content_type":"location",
            }
          ]
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

  #TODO: make it useful
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
    user_id = @fb_params.sender["id"].to_i
    user = User.find_by_fb_id user_id

    if user.nil?
      user = User.new
      user.fb_id = user_id
      user.state_machine = 0
      user.last_message_received = Time.now
      user.profile = get_profile(user_id)
    end

    if @request_type == "TEXT" or @request_type == "CALLBACK"

      # reset statemachine if longer ago than 5 minutes
      if Settings.state_machine_reset_to > 0 and  Time.now - user.last_message_received > (60 * 5)
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
    @msg_meta = nil

    @state_handled = false

    #handle different attachments the user could send
    if type == "TEXT"
      if !fb_params.messaging["message"]["attachments"].nil?
        attachment_type = fb_params.messaging["message"]["attachments"][0]["type"]

        if attachment_type == "location"
          @request_type = "LOCATION"
          @msg_meta = fb_params.messaging["message"]["attachments"][0]["payload"]
        elsif attachment_type == "image"
          @request_type = "IMAGE"
          @msg_meta = fb_params.messaging["message"]["attachments"][0]["payload"]["url"]
        elsif attachment_type == "audio"
          @request_type = "AUDIO"
          @msg_meta = fb_params.messaging["message"]["attachments"][0]["payload"]["url"]
        elsif attachment_type == "fallback"
          @request_type = "ATTACHMENT_UNKNOWN"
          @msg_meta = fb_params.messaging["message"]["attachments"][0]["payload"]
        else
          puts "UNKNOWN ATTACHMENT: "  + attachment_type
        end
      end
    end

    bot_logic


    rescue Exception => e
      puts e.message
      puts e.backtrace.join("\n")
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
    EmojiParser.tokenize(content)
  end

  ## State Machine Module
  def self.state_action(required_state, action)
    if @request_type == "TEXT" or @request_type == "CALLBACK" or @request_type == "LOCATION"
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

    #puts "going state: " + @current_user.state_machine.to_s

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

  ## webview Module

  def self.generate_webview_token(user_id)
    OpenSSL::HMAC.hexdigest('sha1'.freeze, 
                            Rails.application.secrets.secret_key_base,
                            user_id)
  end


  def self.send_webview_button(webview, text='Webview Message Text', button_text='Open Webview')
    params = {
        token: generate_webview_token(@fb_params.sender["id"]),
        user_id: @fb_params.sender["id"]
      }.to_query

    url = ENV["DOMAIN_NAME"] + "/" + webview + "?" + params

    puts url
  
    Bot.deliver(
        recipient: @fb_params.sender,
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'button',
              text: text,
              buttons: [
                { 
                  type: 'web_url',
                  title: button_text,
                  url: url,
                  webview_height_ratio: "compact", #compact, tall, full 
                  messenger_extensions: true,  
                  fallback_url: url
                }
              ]
            }
          }
        }
      )


  end


  ## Setup Module


  def self.set_domain_whitelist
    Facebook::Messenger::Thread.set(
      setting_type: "domain_whitelisting",
      whitelisted_domains: [ ENV["DOMAIN_NAME"] ],
      domain_action_type: "add"
    )
  end

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

  def self.set_bot_menu(options = %W(Reset))
    Facebook::Messenger::Thread.set(
      setting_type: 'call_to_actions',
      thread_state: 'existing_thread',
      call_to_actions: options.map { |option| {type: 'postback', title: option, payload: "#{option.upcase}_BOT"} }
    )
  end

  def self.got_bot_menu?(option)
    @request_type == "CALLBACK" and @fb_params.payload == "#{option.upcase}_BOT"
  end

  #geo utils
  def self.get_address_from_latlng
    #https://console.developers.google.com/flows/enableapi?apiid=geolocation&keyType=SERVER_SIDE&reusekey=true
    response = HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json?latlng=#{@msg_meta["coordinates"]["lat"]},#{@msg_meta["coordinates"]["long"]}&key=#{Settings.googlegeo_api_key}")
    address_infos = JSON.parse(response.body)
    address_infos["results"][0]["formatted_address"]
  end

  def self.get_weather_from_latlng
    response = HTTParty.get("http://api.openweathermap.org/data/2.5/weather?units=metric&lat=#{@msg_meta["coordinates"]["lat"]}&lon=#{@msg_meta["coordinates"]["long"]}&appid=#{Settings.openweathermap_api_key}")
    weather_infos = JSON.parse(response.body)
    puts weather_infos
    weather_infos["main"]
  end

end