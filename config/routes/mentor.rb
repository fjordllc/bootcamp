# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :mentor do
    root to: "home#index", as: :root
    resources :categories, except: %i(destroy)
    resources :practices, only: %i(index)
    resources :courses, except: %i(show destroy)
  end
end
