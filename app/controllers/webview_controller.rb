class WebviewController < ApplicationController
  layout false
  before_filter :verify_webview_token #, except: [:EXCEPT1, :EXCEPT2]

  def verify_webview_token
    if params["token"].nil?
      raise "NO_TOKEN"
    elsif  params["user_id"].nil?
      raise "NO_USER_ID"
    elsif params["token"] != BaseBotLogic::generate_webview_token(params["user_id"])    
      raise "INVALID_TOKEN"
    end        
  end

  def date_picker

  end

  def submit
    render json:{status: "OK"}
  end


end
