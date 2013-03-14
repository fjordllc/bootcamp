Interns::Application.routes.draw do
  root to: 'home#index'

  resources :users
  resources :user_sessions
  resources :practices do
    controller :learnings do
      post   '/start'   => :start
      put    '/finish'  => :finish
      delete '/destroy' => :destroy
    end
  end

  get 'login'  => 'user_sessions#new',     as: :login
  get 'logout' => 'user_sessions#destroy', as: :logout
end
