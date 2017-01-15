require "spec_helper"
require "rails_helper"
require "bot/base_bot_logic"

describe BaseBotLogic do 

  before do
    stub_request_to_be_ok
  end 

  describe "botstack base module" do
    let(:test_message) { "hello world" }
    let(:test_image) { "http://example.com/cat.png" }
    let(:test_coords) { { "coordinates.lat" => 10, "coordinates.long" => 10 } }

    it "receives a hello world message" do
      BaseBotLogic::handle_request(generate_message(test_message), "TEXT") 
      expect(BaseBotLogic::get_message).to eql test_message
    end

    it "receives an image" do
      BaseBotLogic::handle_request(generate_message_image(test_image), "TEXT") 
      expect(BaseBotLogic::get_message).to eql nil
      expect(BaseBotLogic::get_request_type).to eql "IMAGE"
      expect(BaseBotLogic::get_msg_meta).to eql test_image    
    end

    it "receives a location" do
      BaseBotLogic::handle_request(generate_message_location(test_coords), "TEXT") 
      expect(BaseBotLogic::get_message).to eql nil
      expect(BaseBotLogic::get_request_type).to eql "LOCATION"
      expect(BaseBotLogic::get_msg_meta).to eql test_coords    
    end

    it "receives an audio" do
      BaseBotLogic::handle_request(generate_message_audio(test_image), "TEXT") 
      expect(BaseBotLogic::get_message).to eql nil
      expect(BaseBotLogic::get_request_type).to eql "AUDIO"
      expect(BaseBotLogic::get_msg_meta).to eql test_image    
    end

    it "sends a message" do
      expect(BaseBotLogic).to receive(:reply_message).with(test_message)
      BaseBotLogic::reply_message test_message  
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