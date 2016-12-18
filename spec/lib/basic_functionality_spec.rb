require "spec_helper"
require "rails_helper"
require "bot/base_bot_logic"

describe BaseBotLogic do

  let(:test_message) { "hello world" }
  
  describe "botstack base module" do
    it "receives a hello world message" do
      BaseBotLogic::handle_request(generate_message(test_message), "TEXT") 
      expect(BaseBotLogic::get_message).to eql test_message
    end
  end

  describe "botstack emoji module" do

    let(:emoji_token) { ":cat:" }
    let(:emoji_message){ BaseBotLogic::compute_emojis(emoji_token) }

    it "receives an emoji" do
      BaseBotLogic::handle_request(generate_message(emoji_message), "TEXT") 
      message_token = BaseBotLogic::parse_emojis(BaseBotLogic::get_message)
      expect(message_token).to eql emoji_token
    end

  end


end