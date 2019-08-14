# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "home#index"

  get "welcome", to: "welcome#index", as: "welcome"
  get "practices", to: "welcome#practices", as: "practices"
  get "pricing", to: "welcome#pricing", as: "pricing"
  get "faq", to: "welcome#faq", as: "faq"
  get "tos", to: "welcome#tos", as: "tos"
  get "law", to: "welcome#law", as: "law"

  namespace "api" do
    resource :image, controller: "image", only: %i(create)
    resources :grasses, only: %i(show)
    resources :categories, only: %i(index)
    resources :comments, only: %i(index create update destroy)
    resources :available_emojis, only: %i(index)
    resources :reactions, only: %i(create destroy)
    resources :checks, only: %i(index create destroy)
    resources :users, only: %i(index show)
    resources :practices, only: [] do
      resource :learning, only: %i(show update), controller: "practices/learning"
    end
    resources :watches, only: %i(index create destroy)
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
  resource :retirement, only: %i(show new create), controller: "retirement"
  resources :users, only: %i(index show new create) do
    resources :reports, only: %i(index), controller: "users/reports"
    resources :comments, only: %i(index), controller: "users/comments"
    resources :products, only: %i(index), controller: "users/products"
    get "portfolio" => "users/works#index", as: :portfolio
  end

  resource :card, only: %i(show new create edit update), controller: "card"
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
  resources :comments
  resources :pages
  resources :watches
  resources :notifications, only: %i(index show) do
    collection do
      resources :allmarks, only: %i(create), controller: "notifications/allmarks"
    end
  end
  resources :works, except: %i(index)

  resources :questions do
    resources :answers, only: %i(edit create update destroy)
    resource :correct_answer, only: %i(create update), controller: "questions/correct_answer"
  end

  resources :courses, only: :index

  resource :inquiry, only: %i(new create)

  resources :articles
  get "articles/tags/:tag", to: "articles#index", as: :tag

  get "login" => "user_sessions#new", as: :login
  post "user_sessions" => "user_sessions#create"
  get "logout" => "user_sessions#destroy", as: :logout

  get "thanks", to: "static_pages#thanks"
  get "retire", to: "static_pages#retire"
end
