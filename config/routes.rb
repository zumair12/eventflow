# frozen_string_literal: true

Rails.application.routes.draw do
  # Health check

  # Authentication
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  # Root
  root "dashboard#index"

  # Dashboard
  get "dashboard", to: "dashboard#index", as: :dashboard

  # Events with nested bookings
  resources :events do
    collection do
      get :calendar
    end
    member do
      patch :publish
      patch :cancel
    end
    resources :bookings, only: %i[new create], shallow: true
  end

  # Bookings (standalone index, show, cancel, destroy)
  resources :bookings, only: %i[index show destroy] do
    member do
      patch :cancel
    end
  end

  # Venues
  resources :venues

  # Admin namespace
  namespace :admin do
    root "dashboard#index"
    resources :users, except: %i[new create]
    resources :events, only: %i[index show]
    resources :bookings, only: %i[index show]
  end

  # PWA
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Reveal health status on /up
  get "up" => "rails/health#show", as: :rails_health_check
end
