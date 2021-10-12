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

  namespace :scheduler do
    resource :statistic, only: %i(show), controller: "statistic"
    resource :link_checker, only: %i(show), controller: "link_checker"
  end

  namespace "api" do
    resource :session, controller: "session", only: %i(create)
    resource :image, controller: "image", only: %i(create)
    resources :grasses, only: %i(show)
    resources :categories, only: %i(index destroy)
    resources :courses, only: %i() do
      resources :practices, only: %i(index), controller: "/api/courses/practices"
    end
    resources :courses_categories, only: %i() do
      resource :position, only: %i(update), controller: "courses_categories/position"
    end
    resources :notifications, only: %i(index)
    resources :comments, only: %i(index create update destroy)
    resources :answers, only: %i(index create update destroy) do
      resource :correct_answer, only: %i(create update)
    end
    resources :available_emojis, only: %i(index)
    resources :reactions, only: %i(create destroy)
    resources :checks, only: %i(index create destroy)
    resources :mention_users, only: %i(index)
    resources :users, only: %i(index show update)
    resources :user_icon_urls, only: %i(index)
    get "users/tags/:tag", to: "users#index", as: :users_tag, tag: /.+/
    resources :practices, only: %i(index show update) do
      resource :learning, only: %i(show update), controller: "practices/learning"
    end
    resources :reports, only: %i(index)
    namespace "reports" do
      resources :unchecked, only: %i(index)
      resources :recents, only: %i(index)
    end
    resources :watches, only: %i(index)
    namespace "watches" do
      resources :toggle, only: %i(index create destroy)
    end
    resources :memos, only: %i(create update destroy)
    resources :mentor_memos, only: %i(update)
    resources :tags, only: %i(index)
    resources :pages, only: %i(update)
    resources :questions, only: %i(show update)
    resources :followings, only: %i(create update destroy)
    namespace :products do
      resources :unchecked, only: %i(index)
      resources :not_responded, only: %i(index)
      resources :unassigned, only: %i(index)
      resources :self_assigned, only: %i(index)
      resource :checker, only: %i(update), controller: 'checker'
      resource :passed, only: %i(show), controller: 'passed'
    end
    resources :products, only: %i(index)
    namespace :categories_practices do
      resources :position, only: %i(update)
    end
    resources :announcements, except: %i(new edit)
    resources :searchables, only: %i(index)
    resources :niconico_calendars, only: %i(show)
    resources :bookmarks, only: %i(index create destroy)
    resources :events, only: %i(index)
  end

  namespace :admin do
    root to: "home#index", as: :root
    resources :companies, except: %i(show)
    resources :users, only: %i(index show edit update destroy) do
      resource :password, only: %i(edit update), controller: "users/password"
    end
    resources :categories, except: %i(show)
    resources :courses, except: %i(show)
  end

  namespace :current_user do
    resources :reports, only: %i(index)
    resources :products, only: %i(index)
    resources :watches, only: %i(index)
    resources :bookmarks, only: %i(index)
  end

  namespace "partial" do
    resource :git_hub_grass, only: %i(show), controller: "git_hub_grass"
  end

  namespace :users do
    get "tags", to: "tags#index"
  end

  resources :announcements
  resource :retirement, only: %i(show new create), controller: "retirement"
  resources :users, only: %i(index show new create) do
    resources :reports, only: %i(index), controller: "users/reports"
    resources :comments, only: %i(index), controller: "users/comments"
    resources :products, only: %i(index), controller: "users/products"
    resources :questions, only: %i(index), controller: "users/questions"
    get "portfolio" => "users/works#index", as: :portfolio
    patch "graduation", to: "graduation#update", as: :graduation
    get "mail_notification", to: "mail_notification#update", as: :mail_notification
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

  resources :courses, except: %i(show) do
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
  end
  namespace :products do
    resources :unchecked, only: %i(index)
    resources :not_responded, only: %i(index)
    resources :unassigned, only: %i(index)
    resources :self_assigned, only: %i(index)
  end
  resources :products
  namespace :reports do
    resources :unchecked, only: %i(index)
  end
  resources :reports
  resources :pages, param: :slug_or_id
  resources :notifications, only: %i(index show) do
    collection do
      resources :allmarks, only: %i(create), controller: "notifications/allmarks"
    end
  end
  resources :works, except: %i(index)

  resources :questions, only: %i(index show new create destroy)
  resources :courses, only: :index

  resource :inquiry, only: %i(new create)

  resources :articles
  resources :events do
    resources :participations, only: %i(create destroy), controller: "events/participations"
  end

  resources :companies, only: %i(index show) do
    resources :users, only: %i(index), controller: "companies/users"
    resources :reports, only: %i(index), controller: "companies/reports"
    resources :products, only: %i(index), controller: "companies/products"
  end

  resources :generations, only: %i(show index)

  get "articles/tags/:tag", to: "articles#index", as: :tag, tag: /.+/
  get "pages/tags/:tag", to: "pages#index", as: :pages_tag, tag: /.+/
  get "questions/tags/:tag", to: "questions#index", as: :questions_tag, tag: /.+/
  get "users/tags/:tag", to: "users#index", as: :users_tag, tag: /.+/

  namespace :users do
    post "tags/:tag", to: "tags#update", tag: /.+/
    delete "tags/:tag", to: "tags#destroy", tag: /.+/
  end

  get "login" => "user_sessions#new", as: :login
  get "auth/github/callback" => "user_sessions#callback"
  post "user_sessions" => "user_sessions#create"
  get "logout" => "user_sessions#destroy", as: :logout

  get "thanks", to: "static_pages#thanks"
  get "retire", to: "static_pages#retire"

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
