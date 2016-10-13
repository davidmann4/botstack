class BotLogic < BaseBotLogic

  def setup
    set_welcome_message "Welcome! Just send me Images and I will add it to the pictureframe!"
    set_get_started_button "bot_start_payload"
    set_bot_menu
  end

  def cron
  end

  def bot_logic
    ENV["DOMAIN_NAME"] = "https://82be97d0.ngrok.io"

    #binding.pry

    if @request_type == "IMAGE"
    	reply_message "{Cool|Great|Perfect}, added your {image|picture}!"
    	image = Image.new url: @fb_params2
    	image.save!    	
    	reply_message "{Cool|Great|Perfect}, added your {image|picture}!"
    else
    	reply_message "Just send me images and I will add it to the pictureframe!"
    end
  end 

end
