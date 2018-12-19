Rails.application.routes.draw do
  get '/', to: 'home#index'
  resources :alerts
  resources :recipients
  resources :sources
  resources :imports, only: [:create, :new]
  resources :notifications, only: [:create]
end
