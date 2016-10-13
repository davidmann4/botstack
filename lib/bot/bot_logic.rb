

class BotLogic < BaseBotLogic

  def self.setup
    set_welcome_message "Welcome!"
    set_get_started_button "bot_start_payload"
    set_bot_menu
  end

  def self.cron
    broadcast_all ":princess:"
  end

  def self.bot_logic
    ENV["DOMAIN_NAME"] = "https://82be97d0.ngrok.io"

    #binding.pry

    if @request_type == "CALLBACK" and @fb_params.payload == "RESET_BOT"
      @current_user.delete
      reply_message "Removed all your data from our servers."
      return
    end

    state_action 0, :greeting
    state_action 1, :subscribe
    state_action 2, :confirm
    state_action 3, :onboarded
  end

  def self.greeting
    reply_message "To make it a little easy. Could you type your due date again just this way: 28-04-2017?"
    state_go
  end

  def self.subscribe
    due_date = Date.parse get_message

    @current_user.profile = {due_date: due_date.to_s}
    @current_user.save!

    reply_quick_reply "Okay #{due_date.to_s}. Did I get it right?"
    state_go
  rescue ArgumentError
    reply_message "{Sorry I do not undestand this format|Can you try again? Format is DD/MM/YYYY}"
  end

  def self.confirm
    if get_message == "Yes"
      subscribe_user("pregnant")
      state_go
      reply_message "Awwww sweet! You are all set now. I'll start to track your pregnancy for you. Can't wait :bride_with_veil::heart::baby_bottle:"
    else
      reply_message "Ohh Sorry, please use this format: DD/MM/YYYY"
      @current_user.profile = {}
      @current_user.save!
      state_reset
    end
  end

  def self.onboarded
    output_current_week
  end

  ### helper functions

  def self.calculate_current_week
    user_date = Date.parse @current_user.profile[:due_date]
    server_date = Date.parse Time.now.to_s

    40 - ((user_date - server_date).to_i / 7)
  end

  def self.output_current_week
    current_week = calculate_current_week
    reply_message "you are in week number #{current_week}"
  end

end
