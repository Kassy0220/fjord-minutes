Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "home#index"
  get 'pp', to: 'home#pp'
  get 'terms_of_service', to: 'home#terms_of_service'
  resources :meetings, only: [] do
    resources :attendances, only: %i[new create], module: :meetings
  end
  resources :minutes, only: %i[show edit] do
    resources :exports, only: %i[create], module: :minutes
  end
  resources :attendances, only: %i[edit update]
  resources :courses, only: [] do
    resources :members, only: %i[index], module: :courses
    resources :minutes, only: %i[index], module: :courses
  end
  resources :members, only: %i[show] do
    resources :hibernations, only: %i[create], module: :members
  end

  namespace :api do
    resources :meetings, only: [] do
      resources :attendances, only: %i[index], module: :meetings
    end
    resources :minutes, only: %i[update] do
      resources :topics, only: %i[create update destroy], module: :minutes
      resources :meetings, only: %i[update], module: :minutes
    end
  end

  devise_for :members, skip: :all
  devise_for :admins, skip: :all
  devise_scope :member do
    get "/auth/:provider/callback" => "authentications#create"
    get "/auth/failure" => "authentications#failure"
    delete "logout", to: "members/sessions#destroy", as: "logout"
  end

  # Render dynamic PWA files from app/views/pwa/*
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
