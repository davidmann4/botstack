class BotLogic < BaseBotLogic

  def self.setup

  end

  def self.bot_logic
    #basic botstack bot with 3 states:
    state_action 0, :greeting
    state_action 1, :tutorial
    state_action 2, :function
  end

  def self.greeting
    reply_message "hello human!"
    state_go
  end

  def self.tutorial
    reply_message "I will multiplicate numbers by 2!"
    state_go
  end

  def self.function    
    result = get_message.to_i * 2

    if get_message != "0" and result == 0
      reply_message "please send me a number!"
      return
    end

    reply_message result.to_s
  end

end