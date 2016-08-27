

class BotLogic < BaseBotLogic

	def self.bot_logic
		ENV["DOMAIN_NAME"] = "https://7fede8f7.ngrok.io"
		#binding.pry
		#reply_html "<b>hello world </b>"
		
		#reply_message "hello world"
		
		search_request_on_website(
			url: "http://www.chefkoch.de/",
	      	form_name: 'searchform',
	      	result_css_selector: 'li.search-list-item > a',
	      	image_css_selector: 'img'
	    )

		handle_search_result(
			url: "http://www.chefkoch.de",
      		result_css_selector: ".ingredients__container"
    	)

	end

end