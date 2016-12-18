require "spec_helper"
require "rails_helper"
require "bot/base_bot_logic"

describe BaseBotLogic do

  let(:test_message) { "hello world" }

  describe "botstack base_bot_logic" do
    it "receives a hello world message" do
      BaseBotLogic::handle_request(generate_message(:test_message), "TEXT") 
      expect(BaseBotLogic::get_message).to eql :test_message
    end
  end


end