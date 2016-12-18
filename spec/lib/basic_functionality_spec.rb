require "spec_helper"
require "rails_helper"
require "bot/base_bot_logic"

describe BaseBotLogic do
  it "receives a hello world message" do
    response = BaseBotLogic::handle_request(generate_message("hello world"), "TEXT")    
  end
end