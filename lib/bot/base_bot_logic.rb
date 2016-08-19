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

end