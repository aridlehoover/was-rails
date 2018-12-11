Rails.application.routes.draw do
  resources :alerts
  resources :recipients
  resources :sources
end
