# frozen_string_literal: true

Rails.application.routes.draw do
  # この順番が崩れると壊れるので注意
  namespace :users do
    get "tags", to: "tags#index"
    resources :companies, only: %i(index)
  end

  resources :users, only: %i(index show new create) do
    resources :reports, only: %i(index), controller: "users/reports"
    resources :comments, only: %i(index), controller: "users/comments"
    resources :products, only: %i(index), controller: "users/products"
    resources :questions, only: %i(index), controller: "users/questions"
    resources :answers, only: %i(index), controller: "users/answers"
    get "portfolio" => "users/works#index", as: :portfolio
    patch "graduation", to: "graduation#update", as: :graduation
    get "mail_notification", to: "mail_notification#update", as: :mail_notification
  end

  get "users/tags/:tag", to: "users#index", as: :users_tag, tag: /.+/, format: "html"

  namespace :users do
    post "tags/:tag", to: "tags#update", tag: /.+/
    delete "tags/:tag", to: "tags#destroy", tag: /.+/
  end
end
