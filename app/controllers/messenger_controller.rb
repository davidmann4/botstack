
class MessengerController < Messenger::MessengerController
  def webhook
    #logic here
    render nothing: true, status: 200
  end
end