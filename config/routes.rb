Rails.application.routes.draw do

  mount Facebook::Messenger::Server, at: '/bot'
  #post '/bot' , to: 'application#debug'

  get '/subscribe', to: 'application#subscribe'
  get '/cron', to: 'application#cron'
end
