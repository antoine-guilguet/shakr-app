Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  resources :recipes
  resources :realtime_sessions, only: :create
  namespace :agent do
    post "tools/:name", to: "tools#create", as: :tool
  end
  get "voice", to: "voice#show", as: :voice
  get "home", to: "home#index"

  root "home#index"
end
