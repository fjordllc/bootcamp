# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :reports do
    resources :unchecked, only: %i(index)
  end

  resources :reports
end
