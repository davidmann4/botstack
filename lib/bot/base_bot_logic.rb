require 'mechanize'

class BaseBotLogic

  def self.reply_message(msg)
    if @fb_params.first_entry.callback.message?
    Messenger::Client.send(
      Messenger::Request.new(
        Messenger::Elements::Text.new(text: msg),
        @fb_params.first_entry.sender_id
      )
    )
   end
  end

  def self.reply_image(img_url)
    Messenger::Client.send(
      Messenger::Request.new(
        Messenger::Elements::Image.new(url: img_url),
        @fb_params.first_entry.sender_id
      )
    )
  end

  def self.reply_html(html)
    if @fb_params.first_entry.callback.message? or @fb_params.first_entry.callback.postback?
      kit = IMGKit.new("<meta charset='UTF-8'/>"+html, :quality => 100, :width => 300)    
      kit.stylesheets << 'public/search_result.css'

      file = kit.to_file('public/html_response.jpg')
      reply_image(ENV["DOMAIN_NAME"] + "/html_response.jpg")
    end
  end

  #TODO: maje it useful
  def self.reply_button
    if @fb_params.first_entry.callback.message?

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
    if @fb_params.first_entry.callback.message?

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
    if @fb_params.first_entry.callback.message?
      @fb_params.first_entry.callback.text
    else
      nil
    end
  end

  def self.handle_user

    #binding.pry 
    user_id = @fb_params.first_entry.sender_id
    user = User.find_by_fb_id user_id

    if user.nil?
      user = User.new 
      user.fb_id = user_id
      user.state_machine = 0
    end

    user.last_message_received = Time.now
    user.save!

    user
  end

  def self.handle_request(fb_params)
    if fb_params.params[:entry].nil? #wtf is this?
      puts "ERROR NO entry Value"
      return
    end

    @fb_params = fb_params
    @current_user = handle_user
    bot_logic
      
    #rescue Exception => e
    #  puts e
  end



  ## websearch MODULE

  def self.search_request_on_website(options)
    options = {
      form_name: 'searchform',
      result_css_selector: 'li.search-list-item > a',
      image_css_selector: 'img'
    }.merge(options)
    
    if @fb_params.first_entry.callback.message?
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
            bubble = Messenger::Elements::Bubble.new(
              title: link.css(".search-list-item-title").text,
              subtitle: link["title"],
              #item_url: 'http://lorempixel.com/400/400/cats',
              image_url: img["srcset"],
              buttons: [
                Messenger::Elements::Button.new(
                  type: 'postback',
                  title: 'Zutaten Anzeigen',
                  value: 'search_result_' + link["href"]
                )
              ]
            )     

            search_results_bubbles.push(bubble)   
          end
        end

        generic = Messenger::Templates::Generic.new(
          elements: search_results_bubbles
        )

        Messenger::Client.send(
          Messenger::Request.new(generic, @fb_params.first_entry.sender_id)
        )

      end
    end
  end

  def self.handle_search_result(options) 
    options = {
      result_css_selector: '.result'
    }.merge(options)

    puts options

    if @fb_params.first_entry.callback.postback?
      search_url = options[:url] + @fb_params.first_entry.callback.payload
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

  def compute_emojis(content)
    EmojiParser.detokenize(content)
  end

  def parse_emojis(content)
    EmojiParser.tokenize()
  end



end