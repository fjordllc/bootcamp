# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    root to: "home#index", as: :root
    get "test", to: "home#test", as: "test"
    resources :companies, except: %i(show)
    resources :users, only: %i(index show edit update destroy) do
      resource :password, only: %i(edit update), controller: "users/password"
    end
    resources :campaigns, only: %i(new create index edit update)
    resources :faqs, only: %i(index new create edit update), controller: 'faq'
  end
end
