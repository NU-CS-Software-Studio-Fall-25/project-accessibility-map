# frozen_string_literal: true

Rails.application.routes.draw do
  resource :session
  match "/auth/:provider/callback", to: "sessions#create", via: [:get, :post]

  resources :passwords, param: :token
  resources :users, only: [:new, :create, :show] do
    collection do
      get :profile
      patch :update_profile
    end
  end
  # Reviews are nested under locations, not a top-level resource
  resources :locations do
    resources :reviews, only: [:create, :update, :destroy]
    member do
      delete :delete_picture
      post :favorite
      delete :unfavorite
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA is handled via static files (manifest.webmanifest and service-worker.js in public/)
  # Defines the root path route ("/")
  root to: "locations#index"
end
