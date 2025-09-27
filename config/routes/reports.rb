# frozen_string_literal: true

Rails.application.routes.draw do
  resources :reports do
    resources :checks, only: [:create, :destroy]
  end
  namespace :reports do
    resources :unchecked, only: %i[index]
  end
end
