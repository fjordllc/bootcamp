# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :current_user do
    resources :reports, only: %i(index)
    resources :products, only: %i(index)
    resources :watches, only: %i(index)
    resources :bookmarks, only: %i(index)
  end
end
