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
end