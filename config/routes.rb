Rails.application.routes.draw do
  root to: "home#index"
  get "welcome", to: "home#welcome", as: "welcome"

  namespace "api" do
    resource :image, controller: "image", only: %i(create)
    resource :face, controller: "face", only: %i(update)
    resources :faces, only: %i(index)
  end

  namespace :admin do
    root to: "home#index", as: :root
    resources :companies
    namespace :users do
      resources :emails, only: :index
      resources :in_actives, only: :index
    end
    resources :users
    resources :categories, except: %i(show) do
      resource :position, only: %i(update), controller: "categories/position"
    end
  end

  resources :feeds, only: %i(index)
  resources :users do
    resources :practices, only: %i(index), controller: "users/practices"
    resources :reports, only: %i(index), controller: "users/reports"
  end

  resources :user_sessions, only: %i(new create destroy)
  resources :password_resets, only: %i(create edit update)

  resources :practices, shallow: true do
    resource :learning, only: %i(create update destroy)
    resource :position, only: %i(update)
  end
  resources :practices do
    resources :products do
      resources :comments
      resources :checks, only: %i(create)
    end
  end
  resources :reports do
    resources :checks, only: %i(create)
    resources :footprints, only: %i(create)
    resources :comments
  end

  resources :notifications, only: %i(show)
  resources :pages, param: :title

  resources :questions do
    resources :answers, only: %i(edit create update destroy)
    resource :correct_answer, only: :create, controller: "questions/correct_answer"
  end

  resources :courses, only: :index
  resources :chat_notices, only: :create
  get "login" => "user_sessions#new", as: :login
  get "logout" => "user_sessions#destroy", as: :logout
  resource :contacts, only: %i(new create)

  get "thanks", to: "static_pages#thanks"
end
