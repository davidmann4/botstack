class BotLogic < BaseBotLogic

  def self.setup
    set_bot_menu %W(Reset Info)
  end

  def self.bot_logic

    if got_bot_menu? "Reset"
      @current_user.delete
      reply_message "Removed all your data from our servers."
      return
    end

    state_action 0, :greeting
    state_action 1, :onboarded
  end 

  def self.greeting    
    reply_location_button "hello human, send me your location!"
    state_go
  end

  def self.onboarded
    if @request_type == "LOCATION"
      weather = get_weather_from_latlng["temp"]
      reply_message "wetter:" + weather.to_s

      address = get_address_from_latlng
      reply_message address
    end
    
    reply_location_button "you can send me another location!"
  end

end