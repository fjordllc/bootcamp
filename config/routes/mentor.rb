# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :mentor do
    root to: "home#index", as: :root
    resources :categories do
      resources :practices, only: %i(index), controller: "categories/practices"
    end
    resources :practices, only: %i(index new edit create update destroy) do
      resource :submission_answer, only: %i(new edit create update), controller: "practices/submission_answer"
    end
    resources :coding_tests, only: %i(index new edit create update destroy)
    resources :courses, only: %i(index new edit create update) do
      resources :categories, only: %i(index), controller: "courses/categories"
    end
  end
end
