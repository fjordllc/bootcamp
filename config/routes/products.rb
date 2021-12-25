# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :products do
    resources :unchecked, only: %i(index)
    resources :unassigned, only: %i(index)
    resources :self_assigned, only: %i(index)
  end

  resources :products
end
