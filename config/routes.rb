# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "home#index"
  get "welcome", to: "home#welcome", as: "welcome"

  namespace "api" do
    resource :image, controller: "image", only: %i(create)
    resource :face, controller: "face", only: %i(update)
    resources :faces, only: %i(index)
    resources :grasses, only: %i(show)
    resources :categories, only: %i(index)
    resources :practices, only: [] do
      resource :learning, only: %i(show update), controller: "practices/learning"
    end
  end

  namespace :admin do
    root to: "home#index", as: :root
    resources :companies, except: %i(show)
    resources :users, only: %i(index edit update destroy)
    resources :categories, except: %i(show) do
      resource :position, only: %i(update), controller: "categories/position"
    end
  end

  resources :announcements
  resources :feeds, only: %i(index)
  resources :users, only: %i(index show new create destroy) do
    resources :retirements, only: %i(index), controller: "users/retirements"
    resources :practices, only: %i(index), controller: "users/practices"
    resources :reports, only: %i(index), controller: "users/reports"
    resources :comments, only: %i(index), controller: "users/comments"
    resources :products, only: %i(index), controller: "users/products"
  end

  resource :current_user, only: %i(edit update), controller: "current_user"
  resources :searchables, only: %i(index)
  resources :user_sessions, only: %i(new create destroy)
  resources :password_resets, only: %i(create edit update)

  resources :courses, only: %i(index) do
    resources :practices, only: %i(index), controller: "courses/practices" do
      resource :position, only: %i(update), controller: "courses/practices/position"
    end
  end
  resources :courses, except: %i(index)
  resources :practices, except: %i(index) do
    resources :reports, only: %i(index), controller: "practices/reports"
    resources :questions, only: %i(index), controller: "practices/questions"
    resources :products, only: %i(index), controller: "practices/products"
  end
  namespace :products do
    resources :unchecked, only: %i(index)
  end
  resources :products
  namespace :reports do
    resources :unchecked, only: %i(index)
  end
  resources :reports
  resources :checks, only: %i(create)
  resources :comments
  resources :notifications, only: %i(show)
  resources :pages

  resources :questions do
    resources :answers, only: %i(edit create update destroy)
    resource :correct_answer, only: :create, controller: "questions/correct_answer"
  end

  resources :courses, only: :index

  resource :inquiry, only: %i(new create)

  get "login" => "user_sessions#new", as: :login
  post "user_sessions" => "user_sessions#create"
  get "logout" => "user_sessions#destroy", as: :logout

  get "thanks", to: "static_pages#thanks"
  get "retire", to: "static_pages#retire"
end
