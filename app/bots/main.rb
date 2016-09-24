# app/bots/example.rb

include Facebook::Messenger


Bot.on :message do |message|  
  BotLogic::handle_request(message, "TEXT")
end

Bot.on :postback do |postback|
  BotLogic::handle_request(postback, "CALLBACK")
end

Bot.on :optin do |optin|
  BotLogic::handle_request(optin, "OPTIN")
end

Bot.on :delivery do |delivery|
  BotLogic::handle_request(delivery, "DELIVERY")
end
