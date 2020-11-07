# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "home#index"

  get "test", to: "home#test", as: "test"
  get "welcome", to: "welcome#index", as: "welcome"
  get "practices", to: "welcome#practices", as: "practices"
  get "pricing", to: "welcome#pricing", as: "pricing"
  get "faq", to: "welcome#faq", as: "faq"
  get "tos", to: "welcome#tos", as: "tos"
  get "law", to: "welcome#law", as: "law"
  get "coc", to: "welcome#coc", as: "coc"

  namespace :scheduler do
    resource :statistic, only: %i(update), controller: "statistic"
    resource :link_checker, only: %i(update), controller: "link_checker"
  end

  namespace "api" do
    resource :image, controller: "image", only: %i(create)
    resources :grasses, only: %i(show)
    resources :categories, only: %i(index)
    resources :notifications, only: %i(index)
    resources :comments, only: %i(index create update destroy)
    resources :answers, only: %i(index create update destroy) do
      resource :correct_answer, only: %i(create update)
    end
    resources :available_emojis, only: %i(index)
    resources :reactions, only: %i(create destroy)
    resources :checks, only: %i(index create destroy)
    resources :users, only: %i(index show)
    resources :reservations, only: %i(index create destroy)
    resources :practices, only: %i(show update) do
      resource :learning, only: %i(show update), controller: "practices/learning"
    end
    namespace "reports" do
      resources :recents, only: %i(index)
    end
    resources :watches, only: %i(index create destroy)
    resources :memos, only: %i(create update destroy)
    resources :tags, only: %i(index)
    resources :pages, only: %i(update)
    resources :questions, only: %i(update)
    resources :followings, only: %i(create destroy)
  end

  namespace :admin do
    root to: "home#index", as: :root
    resources :companies, except: %i(show)
    resources :users, only: %i(index show edit update destroy) do
      resource :password, only: %i(edit update), controller: "users/password"
    end
    resources :categories, except: %i(show) do
      resource :position, only: %i(update), controller: "categories/position"
    end

    namespace :books do
      resources :qrcodes, only: %i(index show)
    end
    resources :books
    resources :seats, except: %i(show)
  end

  namespace "partial" do
    resource :git_hub_grass, only: %i(show), controller: "git_hub_grass"
  end

  resources :announcements
  resource :retirement, only: %i(show new create), controller: "retirement"
  resources :users, only: %i(index show new create) do
    resources :reports, only: %i(index), controller: "users/reports"
    resources :comments, only: %i(index), controller: "users/comments"
    resources :products, only: %i(index), controller: "users/products"
    get "portfolio" => "users/works#index", as: :portfolio
    patch "graduation", to: "graduation#update", as: :graduation
  end

  resource :card, only: %i(show new create edit update), controller: "card"
  resource :current_user, only: %i(edit update), controller: "current_user" do
    resource :password, only: %i(edit update), controller: "current_user/password"
  end
  resources :searchables, only: %i(index)
  resources :user_sessions, only: %i(new create destroy)
  resources :password_resets, only: %i(create edit update)


  namespace :connection do
    resource :git_hub, only: %i(destroy), controller: "git_hub"
  end

  resources :courses, only: %i(index) do
    resources :practices, only: %i(index), controller: "courses/practices" do
      resource :position, only: %i(update), controller: "courses/practices/position"
    end
  end
  resources :courses, except: %i(index show)
  resources :practices, except: %i(index destroy) do
    resources :reports, only: %i(index), controller: "practices/reports"
    resources :questions, only: %i(index), controller: "practices/questions"
    resources :products, only: %i(index), controller: "practices/products"
  end
  namespace :products do
    resources :unchecked, only: %i(index)
    resources :not_responded, only: %i(index)
  end
  resources :products
  namespace :reports do
    resources :unchecked, only: %i(index)
  end
  resources :reports
  resources :pages
  resources :notifications, only: %i(index show) do
    collection do
      resources :allmarks, only: %i(create), controller: "notifications/allmarks"
      resources :unread, only: %i(index), controller: "notifications/unread", path: :unread
    end
  end
  resources :works, except: %i(index)
  resources :books, only: %i(index show) do
    resources :borrowings, only: %i(create destroy)
    collection do
      resources :borrowed, only: %i(index), controller: "books/borrowed", path: :borrowed
      resources :search_results, only: %i(index), controller: "books/search_results"
    end
  end

  resources :questions
  resources :reservation_calenders, only: %i(index show)
  resources :courses, only: :index

  resource :inquiry, only: %i(new create)

  resources :articles
  resources :events do
    resources :participations, only: %i(create destroy), controller: "events/participations"
  end

  resources :companies, only: %i(index)
  resources :companies, only: %i(show) do
    resources :users, only: %i(index), controller: "companies/users"
    resources :reports, only: %i(index), controller: "companies/reports"
    resources :products, only: %i(index), controller: "companies/products"
  end

  resources :generations, only: %i(show)

  get "articles/tags/:tag", to: "articles#index", as: :tag
  get "pages/tags/:tag", to: "pages#index", as: :pages_tag
  get "questions/tags/:tag", to: "questions#index", as: :questions_tag

  get "login" => "user_sessions#new", as: :login
  get "auth/github/callback" => "user_sessions#callback"
  post "user_sessions" => "user_sessions#create"
  get "logout" => "user_sessions#destroy", as: :logout

  get "thanks", to: "static_pages#thanks"
  get "retire", to: "static_pages#retire"
end
