Interns::Application.routes.draw do
  resources :users
  resources :user_sessions
  resources :practices
  get 'login'  => 'user_sessions#new',     as: :login
  get 'logout' => 'user_sessions#destroy', as: :logout
  root to: 'home#index'
end
