# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :paper do
    root to: "home#index", as: :root
    resource :course_document, only: %i(show)
    resource :exercise_procedure_document, only: %i(show)
  end
end
