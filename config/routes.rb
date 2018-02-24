Rails.application.routes.draw do
  get 'server' => 'server#index'
  get 'server/index'
  get 'server/stats'
  get 'server/start'
  get 'server/restart'

  resources :rooms
  resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
