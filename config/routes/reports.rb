# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :reports do
    resources :unchecked, only: %i[index]
  end
  resources :reports do
    post :comment_by_pjord, on: :member
    resources :checks, only: [:create, :destroy]
  end
end
