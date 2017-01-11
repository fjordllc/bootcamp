Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
  resources :questions

  root to: 'home#index'
  namespace :admin do
    root to: 'home#index', as: :root
    resources :companies
    resources :users
    resources :categories, except: %i(show) do
      resource :position, only: %i(update), controller: 'categories/position'
    end
  end
  resources :feeds, only: %i(index)
  resources :users do
    resources :practices, only: %i(index), controller: 'users/practices'
    resources :reports, only: %i(index), controller: 'users/reports'
  end
  resource :current_user, only: :update, controller: 'current_user'
  resources :user_sessions, only: %i(new create destroy)
  resources :practices, shallow: true do
    resource :learning, only: %i(create update destroy)
    resource :position, only: %i(update)
  end
  resources :reports do
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
  get 'login'  => 'user_sessions#new',     as: :login
  get 'logout' => 'user_sessions#destroy', as: :logout

  resource :contacts, only: %i(new create)
end
