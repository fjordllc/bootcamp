Rails.application.routes.draw do
  resources :questions

  root to: "home#index"
  get "welcome", to: "home#welcome", as: "welcome"
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
  resources :reports do
    resources :checks, only: %i(create)
    resources :footprints, only: %i(create)
    resources :comments
  end
  get "pages/new", to: "pages#new"
  get "pages", to: "pages#index", as: :pages
  post "pages", to: "pages#create"
  get "pages/:title", to: "pages#show", as: :page
  patch "pages/:title", to: "pages#update"
  put "pages/:title", to: "pages#update"
  delete "pages/:title", to: "pages#destroy"
  get "pages/:title/edit", to: "pages#edit"
  resources :questions do
    resources :answers, only: %i(edit create update destroy)
    resource :correct_answer, only: :create, controller: "questions/correct_answers"
  end
  resources :courses, only: :index
  resources :chat_notices, only: :create
  get "login"  => "user_sessions#new",     as: :login
  get "logout" => "user_sessions#destroy", as: :logout
  resource :contacts, only: %i(new create)

  get "thanks", to: "static_pages#thanks"
end
