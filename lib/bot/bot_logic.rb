

class BotLogic < BaseBotLogic

	def self.bot_logic
		ENV["DOMAIN_NAME"] = "https://06eeff44.ngrok.io"

		#search_request_on_website(
		#    url: "http://www.chefkoch.de/",
		#    form_name: 'searchform',
		#    result_css_selector: '.search-list-item > a',
		#    image_css_selector: 'img'
		#)

		#handle_search_result(
		#    url: "http://www.chefkoch.de",
		#    result_css_selector: ".ingredients__container"
		#)
		
		state_action 0, :greeting
		state_action 1, :turorial
		state_action 2, :bye

		puts @state_handled
	end

	def self.greeting
		reply_message "greeting"
		state_go
	end 

	def self.turorial
		reply_message "turorial"
		state_go
	end 

	def self.bye
		reply_message "bye"
		state_reset
	end 

end