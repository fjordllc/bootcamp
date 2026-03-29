# frozen_string_literal: true

Rails.application.routes.draw do
  resources :textbooks, only: %i[index show] do
    resources :chapters, only: %i[show], controller: 'textbooks/chapters' do
      resources :sections, only: %i[show], controller: 'textbooks/sections'
    end
  end

  namespace :api do
    namespace :textbooks do
      resources :reading_progresses, only: %i[create update]
      resources :term_explanations, only: %i[show]
      resources :piyo_chat_messages, only: %i[index create]
      resources :piyo_chat_messages, only: %i[index create]
    end
  end
end
