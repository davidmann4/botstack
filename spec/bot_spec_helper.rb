require 'facebook/messenger'
include Facebook::Messenger
require "json"

module BotSpecHelper
  def generate_message(text, user=1)
  	payload = {
          'sender' => {
            'id' => '2'
          },
          'recipient' => {
            'id' => '3'
          },
          'timestamp' => 145_776_419_762_7,
          'message' => {
            'mid' => 'mid.1457764197618:41d102a3e1ae206a38',
            'seq' => 73,
            'text' => text
          }
        }

  	Facebook::Messenger::Incoming.parse(payload)  	
  end 


  def generate_message_file_attachment(type, url, user=1)
    payload = {
          'sender' => {
            'id' => '2'
          },
          'recipient' => {
            'id' => '3'
          },
          'timestamp' => 145_776_419_762_7,
          'message' => {
            'mid' => 'mid.1457764197618:41d102a3e1ae206a38',
            'seq' => 73,
            'text' => "",
            "attachments" => [
              {
                "type" => type,
                "payload" => {
                  "url" => url
                }
              }
            ]
          }          
        }

    Facebook::Messenger::Incoming.parse(payload)    
  end

  def generate_message_image(url, user=1)
    generate_message_file_attachment("image", url, user=1)
  end 

  def generate_message_audio(url, user=1)
    generate_message_file_attachment("audio", url, user=1)
  end 

  def generate_message_video(url, user=1)
    generate_message_file_attachment("video", url, user=1)
  end 

  def generate_message_file(url, user=1)
    generate_message_file_attachment("file", url, user=1)
  end 

  def generate_message_location(location, user=1)
    payload = {
          'sender' => {
            'id' => '2'
          },
          'recipient' => {
            'id' => '3'
          },
          'timestamp' => 145_776_419_762_7,
          'message' => {
            'mid' => 'mid.1457764197618:41d102a3e1ae206a38',
            'seq' => 73,
            'text' => "",
            "attachments" => [
              {
                "type" => "location",
                "payload" => location
              }
            ]
          }          
        }

    Facebook::Messenger::Incoming.parse(payload)    
  end  

  def stub_request_to_be_ok    
    stub_request(:post, /graph.facebook.com/).
    to_return(:status => 200, :body => "", :headers => {})
  end

  def send_text_expect_text(send_text, receive_text)    
    expect(BaseBotLogic).to receive(:reply_message).with(receive_text)
    BotLogic::handle_request(generate_message(send_text), "TEXT") 
  end


end