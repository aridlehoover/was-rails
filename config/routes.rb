Rails.application.routes.draw do
  get '/', to: 'home#index'
  resources :alerts
  resources :recipients
  resources :sources
end
