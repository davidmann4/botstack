Rails.application.routes.draw do

  mount Facebook::Messenger::Server, at: '/bot'

  get '/subscribe', to: 'application#subscribe'
  
end
