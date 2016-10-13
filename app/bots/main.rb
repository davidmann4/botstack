# app/bots/example.rb

include Facebook::Messenger


Bot.on :message do |message|
  $bot.handle_request(message, "TEXT")
end

Bot.on :postback do |postback|
  $bot.handle_request(postback, "CALLBACK")
end

Bot.on :optin do |optin|
  $bot.handle_request(optin, "OPTIN")
end

Bot.on :delivery do |delivery|
  #$bot.handle_request(delivery, "DELIVERY")
end
