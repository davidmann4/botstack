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

  def self.webform(url)
    a = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }

    a.get(url) do |page|
      search_result = page.form_with(:name => 'searchform') do |search|
        search.suche = get_message
      end.submit

      search_result.search("li.search-list-item > a").each  do |link|
        puts link["title"]
      end
    end
  end

end