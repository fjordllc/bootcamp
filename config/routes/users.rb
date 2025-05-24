# frozen_string_literal: true

Rails.application.routes.draw do
  # この順番が崩れると壊れるので注意
  namespace :users do
    get "tags", to: "tags#index"
    resources :courses, only: %i(index)
    resources :companies, only: %i(index)
    resources :areas, only: %i(index)
    get "areas/:area", to: "areas#show", as: :area
  end

  resources :users, only: %i(index show new create) do
    resources :reports, only: %i(index), controller: "users/reports"
    resources :comments, only: %i(index), controller: "users/comments"
    resources :products, only: %i(index), controller: "users/products"
    resources :questions, only: %i(index), controller: "users/questions"
    resources :answers, only: %i(index), controller: "users/answers"
    resources :micro_reports, only: %i[index create destroy], controller: "users/micro_reports"
    get "portfolio" => "users/works#index", as: :portfolio
    patch "graduation", to: "graduation#update", as: :graduation
    resource :mail_notification, only: %i(edit update), controller: "users/mail_notification"
  end

  get "users/tags/:tag", to: "users#index", as: :users_tag, tag: /.+/, format: "html"

  namespace :users do
    post "tags/:tag", to: "tags#update", tag: /.+/
    delete "tags/:tag", to: "tags#destroy", tag: /.+/
  end
end
