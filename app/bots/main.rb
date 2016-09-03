# app/bots/example.rb

include Facebook::Messenger


Bot.on :message do |message|  
  BotLogic::handle_request(message)
end

Bot.on :postback do |postback|
  BotLogic::handle_request(postback)
end

Bot.on :optin do |optin|
  BotLogic::handle_request(optin)
end

Bot.on :delivery do |delivery|
  #BotLogic::handle_request(delivery)
end