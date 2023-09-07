# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :mentor do
    root to: "home#index", as: :root
    resources :categories do
      resources :practices, only: %i(index), controller: "categories/practices"
    end
    resources :practices, only: %i(index)
    resources :courses, only: %i(index new edit create update) do
      resources :practices, only: %i(index), controller: "courses/practices"
      resources :categories, only: %i(index), controller: "courses/categories"
    end
    resources :practices, only: %i(new edit)
  end
end
