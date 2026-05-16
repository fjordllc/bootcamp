# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :mentor do
    root to: 'home#index', as: :root
    resources :categories do
      resources :practices, only: %i[index], controller: 'categories/practices'
    end
    resources :practices, only: %i[index new edit create update destroy] do
      resources :coding_tests, only: %i[index], controller: 'practices/coding_tests'
      resource :submission_answer, only: %i[new edit create update], controller: 'practices/submission_answer'
    end
    resources :coding_tests, only: %i[index new edit create update destroy]
    resources :courses, only: %i[index new edit create update] do
      resources :categories, only: %i[index], controller: 'courses/categories'
    end
    resources :survey_questions, except: %i[show destroy]
    resources :textbooks, only: %i[index new create edit update destroy] do
      resources :chapters, only: %i[new create edit update destroy], controller: 'textbooks/chapters' do
        resources :sections, only: %i[new create edit update destroy], controller: 'textbooks/sections'
      end
    end
    resources :surveys do
      resources :survey_questions, only: %i[index], controller: 'surveys/survey_question_listings'
      resources :survey_answers, only: %i[index show], controller: 'surveys/survey_answers'
      resource :survey_result, only: %i[show], controller: 'surveys/survey_result'
    end
  end
end
