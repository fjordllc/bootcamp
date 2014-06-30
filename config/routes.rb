Interns::Application.routes.draw do
  root to: 'home#index'
  namespace :admin do
    root to: 'home#index'
    resources :companies
    resources :categories do
      resource :position, only: %i(update), controller: 'categories/position'
    end
  end
  resources :feeds, only: %i(index)
  resources :companies, only: %i(index show)
  resources :users do
    resources :practices, only: %i(index), controller: 'users/practices'
  end
  resource :current_user, only: :update, controller: 'current_user'
  resources :user_sessions, only: %i(new create destroy)
  resources :practices, shallow: true do
    resource :learning, only: %i(create update destroy)
    resource :position, only: %i(update)
  end
  resources :courses, only: :index
  resources :chat_notices, only: :create
  get 'application' => 'home#application', as: :application
  get 'login'  => 'user_sessions#new',     as: :login
  get 'logout' => 'user_sessions#destroy', as: :logout
end
