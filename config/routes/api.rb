# frozen_string_literal: true

Rails.application.routes.draw do
  namespace 'api' do
    namespace 'admin' do
      resource :count, controller: 'count', only: %i(show)
    end
    namespace 'mentor' do
      resources :practices, only: %i(index)
    end
    resource :session, controller: "session", only: %i(create)
    resource :image, controller: "image", only: %i(create)
    resources :grasses, only: %i(show)
    resources :categories, only: %i(index destroy)
    resources :courses, only: %i() do
      resources :practices, only: %i(index), controller: "/api/courses/practices"
    end
    resources :courses_categories, only: %i() do
      resource :position, only: %i(update), controller: "courses_categories/position"
    end
    resources :categories_practices, only: %i() do
      resource :position, only: %i(update), controller: "categories_practices/position"
    end
    resources :notifications, only: %i(index)
    resources :subscriptions, only: %i(index)
    resources :comments, only: %i(index create update destroy)
    resources :answers, only: %i(index create update destroy) do
      resource :correct_answer, only: %i(create update)
    end
    resources :available_emojis, only: %i(index)
    resources :reactions, only: %i(create destroy)
    resources :checks, only: %i(index create destroy)
    resources :mention_users, only: %i(index)
    namespace :users do
      resources :companies, only: %i(index)
    end
    resources :users, only: %i(index show update)
    resources :user_icon_urls, only: %i(index)
    get "users/tags/:tag", to: "users#index", as: :users_tag, tag: /.+/
    resources :practices, only: %i(index show update) do
      resource :learning, only: %i(show update), controller: "practices/learning" do
        resource :completion_message, only: %i(update), controller: "practices/learning/completion_message"
      end
    end
    resources :coding_test_submissions, only: %i(create)
    resources :reports, only: %i(index)
    namespace "reports" do
      resources :unchecked, only: %i(index) do
        get 'counts', on: :collection
      end
      resources :recents, only: %i(index)
    end
    resources :watches, only: %i(index)
    namespace "watches" do
      resources :toggle, only: %i(index create destroy)
    end
    resources :mentor_memos, only: %i(update)
    resources :tags, only: %i(index update)
    resources :pages, only: %i(update)
    resources :questions, only: %i(index show update)
    resources :followings, only: %i(create update destroy)
    namespace :products do
      resources :unchecked, only: %i(index)
      resources :unassigned, only: %i(index) do
        get 'counts', on: :collection
      end
      resources :self_assigned, only: %i(index)
      resource :checker, only: %i(show update destroy), controller: 'checker'
      resource :passed, only: %i(show), controller: 'passed'
    end
    resources :products, only: %i(index show)
    resources :searchables, only: %i(index)
    resources :bookmarks, only: %i(index create destroy)
    resources :events, only: %i(index)
    resources :report_templates, only: %i(create update)
    resources :markdown_tasks, only: %i(create)
    namespace :talks do
      resources :action_uncompleted, only: %i(index)
    end
    resources :talks, only: %i(index update)
    resources :generations, only: %i(index show) do
      resources :users, only: %i(index), controller: "/api/generations/users"
    end
    resources :regular_events, only: %i(index)
    resources :books, only: %i(index)
    resources :courses, only: %i(index)
    resources :survey_question_listings, only: %i() do
      resource :position, only: %i(update), controller: "survey_question_listings/position"
    end
    resources :reading_circles, only: %i(index)
    resources :movies, only: %i(index update)
    resources :metadata, only: %i(index)
  end
end
