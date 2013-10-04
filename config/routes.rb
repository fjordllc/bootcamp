Interns::Application.routes.draw do
  root to: 'home#index'
  namespace :admin do
    root to: 'home#index'
    resources :companies
    resources :categories
  end
  resources :companies, only: %w(index show)
  resources :users
  resources :user_sessions, only: %w(new create destroy)
  resources :practices do
    resource :learnings, only: %w(create update destroy)
  end
  get 'application' => 'home#application', as: :application
  get 'login'  => 'user_sessions#new',     as: :login
  get 'logout' => 'user_sessions#destroy', as: :logout
end
