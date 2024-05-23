# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :paper do
    root to: "home#index", as: :root
  end
end
