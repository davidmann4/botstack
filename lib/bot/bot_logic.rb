class BotLogic < BaseBotLogic

  def self.setup
    set_welcome_message "Welcome! Just send me Images and I will add it to the pictureframe!"
    set_get_started_button "bot_start_payload"
    set_bot_menu
  end

  def self.cron
  end

  def self.bot_logic
    ENV["DOMAIN_NAME"] = "https://82be97d0.ngrok.io"

    #binding.pry

    if @fb_params.sender["id"] = 1200872273321307

    	if get_message == "reset"
    		reply_message "Database wiped!"
    		Image.delete_all
    	end
    end

    if @request_type == "IMAGE"    	
    	image = Image.new url: @fb_params2["url"]

    	image.save!    	
    	reply_message "{Cool|Great|Perfect}, added your {image|picture}!"
    else
    	reply_message "Just send me images and I will add it to the pictureframe!"
    end
  end 

end

