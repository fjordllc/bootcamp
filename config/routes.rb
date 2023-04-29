# frozen_string_literal: true

Rails.application.routes.draw do
  resources :surveys do
    resources :survey_questions, only: %i(index), controller: "surveys/survey_question_listings"
  end
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
  resources :announcements
  resource :retirement, only: %i(show new create), controller: "retirement"
  resource :hibernation, only: %i(show new create), controller: "hibernation"
  resource :comeback, only: %i(new create), controller: "comeback"
  resource :current_user, only: %i(edit update), controller: "current_user" do
    resource :password, only: %i(edit update), controller: "current_user/password"
  end
  resources :searchables, only: %i(index)
  resources :user_sessions, only: %i(new create destroy)
  resources :password_resets, only: %i(create edit update)
  resources :courses, only: %i(index new create) do
    resources :practices, only: %i(index), controller: "courses/practices"
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
  namespace :notification do
    resource :redirector, only: %i(show), controller: "redirector"
  end
  resources :notifications, only: %i(index show) do
    collection do
      resources :allmarks, only: %i(create), controller: "notifications/allmarks"
      resource :read_by_category, only: %i(create), controller: "notifications/read_by_category"
    end
  end
  resources :works, except: %i(index)
  namespace :talks do
    resources :action_uncompleted, only: %i(index)
  end
  resources :talks, only: %i(index show)
  resources :questions, only: %i(index show new create destroy)
  resources :courses, only: :index
  resource :inquiry, only: %i(new create)
  resources :articles
  resources :survey_questions, except: %i(show destroy)
  namespace :events do
    resources :calendars, only: %i(index)
  end
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
  namespace :stripe do
    resource :webhook, only: %i(create)
  end
  resources :books, except: %i(show)
  resources :generations, only: %i(show index)
  resource :billing_portal, only: :create, controller: "billing_portal"
  resources :external_entries, only: %i(index)
  resources :categories, only: [] do
    resources :practices, only: %i(index), controller: "categories/practices"
  end
  get "articles/tags/:tag", to: "articles#index", as: :tag, tag: /.+/
  get "pages/tags/:tag", to: "pages#index", as: :pages_tag, tag: /.+/, format: "html"
  get "questions/tags/:tag", to: "questions#index", as: :questions_tag, tag: /.+/, format: "html"
  get "login" => "user_sessions#new", as: :login
  get "auth/github/callback" => "user_sessions#callback"
  post "user_sessions" => "user_sessions#create"
  get "logout" => "user_sessions#destroy", as: :logout
  get "thanks", to: "static_pages#thanks"
  resource :buzz, only: %i(show edit update), controller: "buzz"
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  mount GoodJob::Engine => 'good_job'
end
