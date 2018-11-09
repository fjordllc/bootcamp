# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "home#index"
  get "welcome", to: "home#welcome", as: "welcome"

  namespace "api" do
    resource :image, controller: "image", only: %i(create)
    resource :face, controller: "face", only: %i(update)
    resources :faces, only: %i(index)
    resources :practices, only: [] do
      resource :learning, only: %i(show update), controller: "practices/learning"
    end
  end

  namespace :admin do
    root to: "home#index", as: :root
    resources :companies
    resources :users, except: %i(show)
    resources :categories, except: %i(show) do
      resource :position, only: %i(update), controller: "categories/position"
    end
  end

  resources :announcements
  resources :feeds, only: %i(index)
  resources :users do
    resources :practices, only: %i(index), controller: "users/practices"
    resources :reports, only: %i(index), controller: "users/reports"
    resources :comments, only: %i(index), controller: "users/comments"
    resources :products, only: %i(index), controller: "users/products"
  end

  resources :user_sessions, only: %i(new create destroy)
  resources :password_resets, only: %i(create edit update)

  resources :practices, shallow: true do
    resource :position, only: %i(update)
    resources :reports, only: %i(index), controller: "practices/reports"
    resources :questions, only: %i(index), controller: "practices/questions"
    resources :products, only: %i(index), controller: "practices/products"
  end
  resources :practices do
    resources :products do
      resources :checks, only: %i(create)
    end
  end
  resources :reports do
    resources :checks, only: %i(create)
    resources :footprints, only: %i(create)
  end
  resources :comments
  resources :notifications, only: %i(show)
  resources :pages

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
  get "retire", to: "static_pages#retire"
end
