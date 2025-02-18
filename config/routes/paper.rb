# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :paper do
    root to: "home#index", as: :root
    resource :exercise_procedure_document, only: %i(show), controller: "exercise_procedure_document"
  end
end
