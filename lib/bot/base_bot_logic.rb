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

  def self.reply_image(img_url)
    Messenger::Client.send(
      Messenger::Request.new(
        Messenger::Elements::Image.new(url: img_url),
        @fb_params.first_entry.sender_id
      )
    )
  end

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
    @fb_params = fb_params
    @current_user = handle_user
    bot_logic
  end

  def self.search_website_and_reply_with_bubbles(url)
    if @fb_params.first_entry.callback.message?
      a = Mechanize.new { |agent|
        agent.user_agent_alias = 'Mac Safari'
      }

      a.get(url) do |page|
        search_result = page.form_with(:name => 'searchform') do |search|
          search.suche = get_message
        end.submit

        search_results_bubbles = []

        search_result.search("li.search-list-item > a").each  do |link|
          img = link.css("img").first
          puts img
          puts link.css(".search-list-item-title")

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

  def self.handle_search_result(url)    

    if @fb_params.first_entry.callback.postback?
      search_url = url + @fb_params.first_entry.callback.payload
      search_url['search_result_'] = ''
      puts search_url

      a = Mechanize.new { |agent|
        agent.user_agent_alias = 'Mac Safari'
      }

      a.get(search_url) do |page|
        #puts page.content
        #document = Nokogiri::HTML(page.content)
        results = page.search(".ingredients__container").first

        kit = IMGKit.new("<meta charset='UTF-8'/>"+results.to_html, :quality => 100, :width => 300)    
        kit.stylesheets << 'public/search_result.css'

        file = kit.to_file('public/Z33V12.jpg')
        reply_image(ENV["DOMAIN_NAME"] + "/Z33V12.jpg")
      end
    end
  end

end