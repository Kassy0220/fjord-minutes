Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "home#index"
  resources :minutes, only: [:index, :show, :edit] do
    resources :attendances, only: [ :new, :create ], module: :minutes
    resources :exports, only: [ :create ], module: :minutes
  end
  resources :attendances, only: [ :edit, :update ]
  resources :courses, only: [] do
    resources :members, only: [:index], module: :courses
    resources :minutes, only: [:index], module: :courses
  end
  resources :members, only: [:show] do
    resources :hibernations, only: [:create], module: :members
  end

  namespace :api do
    resources :minutes, only: [ :update ] do
      resources :topics, only: [ :create, :update, :destroy ], module: :minutes
      resources :attendances, only: [ :index ], module: :minutes
    end
  end

  devise_for :members, skip: :all
  devise_for :admins, skip: :all
  devise_scope :member do
    get "/auth/:provider/callback" => "authentications#create"
    delete "logout", to: "members/sessions#destroy", as: "logout"
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
