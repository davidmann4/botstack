class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  def subscribe
  	Facebook::Messenger::Subscriptions.subscribe

  	render json: {
    	botstack_server: "OK"
    }
  end

  def cron
  	$bot.cron

  	render json: {
    	botstack_server: "OK"
    }
  end

  def images
    @images = Image.all
    render json: @images 
  end


end
