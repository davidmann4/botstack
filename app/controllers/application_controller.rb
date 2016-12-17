class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  skip_before_action :verify_authenticity_token

  def subscribe
  	Facebook::Messenger::Subscriptions.subscribe

  	render json: {
    	botstack_server: "OK"
    }
  end

  def cron
  	BotLogic::cron

  	render json: {
    	botstack_server: "OK"
    }
  end

  def debug
    log_headers 
    logger.info "== output as json start =="
    Rails.logger.debug params.to_json  
    logger.info "== output as json end =="  

    #Rails.logger.debug @request.body.read
    Rails.logger.debug request.body.read 

    render json: {
      botstack_server: "OK"
    }
  end


  def log_headers
    http_envs = {}.tap do |envs|
      request.headers.each do |key, value|
        envs[key] = value if key.downcase.starts_with?('http')
      end
    end

    logger.info "Received #{request.method.inspect} to #{request.url.inspect} from #{request.remote_ip.inspect}. Processing with headers #{http_envs.inspect} and params #{params.inspect}"
  end


end
