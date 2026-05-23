# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :products do
    resources :unchecked, only: %i(index)
    resources :unassigned, only: %i(index)
    resources :self_assigned, only: %i(index)
    resources :checker_assignments, only: %i[create destroy]
  end

  resources :products do
    post :review_by_pjord, on: :member
    resources :checks, only: %i[create destroy]
  end
end
