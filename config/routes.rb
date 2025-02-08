Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "home#index"
  get 'pp', to: 'home#pp'
  get 'terms_of_service', to: 'home#terms_of_service'
  resources :minutes, only: [:show, :edit] do
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

  # Render dynamic PWA files from app/views/pwa/*
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
