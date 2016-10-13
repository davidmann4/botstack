
class MessengerController < Messenger::MessengerController

  def webhook
    $bot.handle_request(fb_params)

    render nothing: true, status: 200
  end

end
