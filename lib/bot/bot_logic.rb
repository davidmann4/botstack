

class BotLogic < BaseBotLogic

	def self.bot_logic
		#webform "http://www.chefkoch.de/"
		search_website_and_reply_with_bubbles "http://www.chefkoch.de/"
		handle_search_result "http://www.chefkoch.de/"

	end

end