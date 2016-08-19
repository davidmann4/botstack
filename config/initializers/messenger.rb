Messenger.configure do |config|
  config.verify_token      = Settings.verify_token
  config.page_access_token = Settings.page_access_token
  puts "\e[36m" + "Verify the bot with the following verify_token :" + Settings.verify_token + "\e[0m"
end