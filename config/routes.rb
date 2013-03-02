Interns::Application.routes.draw do
  resources :users
  resources :practices

  get "oauth/callback" => "oauths#callback"
  get "oauth/:provider" => "oauths#oauth", :as => :auth_at_provider
  get 'logout' => 'user_sessions#destroy', as: :logout
  root :to => 'home#index'
end
