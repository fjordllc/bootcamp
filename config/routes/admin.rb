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
    resources :inquiries, only: %i(index show)
    resources :corporate_training_inquiries, only: %i(index show)
    resources :invitation_url, only: %i(index)
    resources :faqs, only: %i(index new create show edit update destroy)
    resources :faq_categories, only: %i(index new create edit update destroy) do
      resources :faqs, only: %i(index update), controller: 'faq_categories/faqs'
    end
    resources :grant_course_applications, only: %i(index show)
    resources :course_diffs, only: %i(index show)
  end
end
