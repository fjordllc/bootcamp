# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "home#index"
  get "test", to: "home#test", as: "test"
  get "welcome", to: "welcome#index", as: "welcome"
  get "practices", to: "welcome#practices", as: "practices"
  get "pricing", to: "welcome#pricing", as: "pricing"
  get "training", to: "welcome#training", as: "training"
  get "faq", to: "welcome#faq", as: "faq"
  get "tos", to: "welcome#tos", as: "tos"
  get "pp", to: "welcome#pp", as: "pp"
  get "law", to: "welcome#law", as: "law"
  get "coc", to: "welcome#coc", as: "coc"
  draw :scheduler
  draw :api
  draw :admin
  draw :mentor
  draw :current_user
  draw :partial
  draw :users
  draw :connection
  draw :products
  draw :reports
  resources :featured_entries, only: %i(index)
  resources :announcements
  resource :retirement, only: %i(show new create), controller: "retirement"
  resource :hibernation, only: %i(show new create), controller: "hibernation"
  resource :current_user, only: %i(edit update), controller: "current_user" do
    resource :password, only: %i(edit update), controller: "current_user/password"
  end
  resources :searchables, only: %i(index)
  resources :user_sessions, only: %i(new create destroy)
  resources :password_resets, only: %i(create edit update)
  resources :courses, only: %i(index new create) do
    resources :practices, only: %i(index), controller: "courses/practices" do
      collection do
        resources :sort, only: %i(index), controller: "courses/practices/sort"
      end
    end
    resources :categories, only: %i(index), controller: "courses/categories"
  end
  resources :practices, except: %i(index destroy) do
    resources :reports, only: %i(index), controller: "practices/reports"
    resources :questions, only: %i(index), controller: "practices/questions"
    resources :products, only: %i(index), controller: "practices/products"
    resources :pages, only: %i(index), controller: "practices/pages"
    resource :completion, only: %i(show), controller: "practices/completion"
  end
  resources :pages, param: :slug_or_id
  resources :notifications, only: %i(index show) do
    collection do
      resources :allmarks, only: %i(create), controller: "notifications/allmarks"
      resource :read_by_category, only: %i(create), controller: "notifications/read_by_category"
    end
  end
  resources :works, except: %i(index)
  namespace :talks do
    resources :unreplied, only: %i(index)
  end
  resources :talks, only: %i(index show)
  resources :questions, only: %i(index show new create destroy)
  resources :courses, only: :index
  resource :inquiry, only: %i(new create)
  resources :articles
  resources :events do
    resources :participations, only: %i(create destroy), controller: "events/participations"
  end
  resources :regular_events do
    resources :participations, only: %i(create destroy), controller: "regular_events/participations"
  end
  resources :companies, only: %i(index show) do
    resources :users, only: %i(index), controller: "companies/users"
    resources :reports, only: %i(index), controller: "companies/reports"
    resources :products, only: %i(index), controller: "companies/products"
  end
  resources :books, except: %i(show)
  resources :generations, only: %i(show index)
  resource :billing_portal, only: :create, controller: "billing_portal"
  get "articles/tags/:tag", to: "articles#index", as: :tag, tag: /.+/
  get "pages/tags/:tag", to: "pages#index", as: :pages_tag, tag: /.+/, format: "html"
  get "questions/tags/:tag", to: "questions#index", as: :questions_tag, tag: /.+/, format: "html"
  get "login" => "user_sessions#new", as: :login
  get "auth/github/callback" => "user_sessions#callback"
  post "user_sessions" => "user_sessions#create"
  get "logout" => "user_sessions#destroy", as: :logout
  get "thanks", to: "static_pages#thanks"
  get "retire", to: "static_pages#retire"
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
