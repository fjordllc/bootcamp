# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    root to: "home#index", as: :root
    resources :companies, except: %i(show)
    resources :users, only: %i(index show edit update destroy) do
      resource :password, only: %i(edit update), controller: "users/password"
    end
    resources :categories, except: %i(show)
    resources :courses, except: %i(show)
  end
end
