Rails.application.routes.draw do

  mount Facebook::Messenger::Server, at: '/bot'

  get '/subscribe', to: 'application#subscribe'
  get '/cron', to: 'application#cron'

  get '/images', to: 'application#images'
end
