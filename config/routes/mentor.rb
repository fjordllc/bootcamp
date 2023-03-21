# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :mentor do
    root to: "home#index", as: :root
    resources :categories, except: %i(new create)
    resources :practices, only: %i(index)
    resources :courses, only: %i(index edit update)
  end
end
