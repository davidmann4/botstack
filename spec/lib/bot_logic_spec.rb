require "spec_helper"
require "rails_helper"
require "bot/base_bot_logic"

describe BotLogic do 

  before do
    stub_request_to_be_ok
  end 

  describe "botstack base module" do

    it "test always sunny case" do
      send_text_expect_text "Hello bot!", "hello human!"
      send_text_expect_text "cool", "I will multiplicate numbers by 2!"
      send_text_expect_text "2", "4"
      send_text_expect_text "4", "8"
      send_text_expect_text "1", "2"
      send_text_expect_text "test", "please send me a number!"
      send_text_expect_text "0", "0"
      send_text_expect_text "2147483647", (2147483647 * 2).to_s #big number test
    end

  end
end