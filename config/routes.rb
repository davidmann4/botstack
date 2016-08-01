Rails.application.routes.draw do

  mount Messenger::Engine, at: "/messenger"


end
