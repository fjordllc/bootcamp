Interns::Application.routes.draw do
  root to: 'home#index'

  resources :users
  resources :user_sessions
  resources :practices
  get 'login'  => 'user_sessions#new',     as: :login
  get 'logout' => 'user_sessions#destroy', as: :logout
end
