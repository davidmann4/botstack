Facebook::Messenger.configure do |config|
  config.verify_token  = Settings.verify_token
  config.access_token = Settings.page_access_token
  config.app_secret = Settings.app_secret

  puts "\e[36m" + "Verify the bot with the following verify_token :" + Settings.verify_token + "\e[0m"
  

  BotLogic::setup()
end