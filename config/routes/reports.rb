# frozen_string_literal: true

Rails.application.routes.draw do
  resources :reports do
    collection do
      get :unchecked
    end
    resources :checks, only: [:create, :destroy]
  end
end
