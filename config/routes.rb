Interns::Application.routes.draw do
  root to: 'home#index'

  resources :users
  resources :user_sessions
  resources :practices do
    resource :learnings, only: %w[create update destroy]
  end

  get 'login'  => 'user_sessions#new',     as: :login
  get 'logout' => 'user_sessions#destroy', as: :logout
end
