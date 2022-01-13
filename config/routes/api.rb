# frozen_string_literal: true

Rails.application.routes.draw do
  namespace 'api' do
    namespace 'admin' do
      resource :count, controller: 'count', only: %i(show)
      resources :companies, controller: 'companies', only: %i(index destroy)
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
      resources :worried, only: %i(index)
    end
    resources :users, only: %i(index show update)
    resources :user_icon_urls, only: %i(index)
    get "users/tags/:tag", to: "users#index", as: :users_tag, tag: /.+/
    resources :practices, only: %i(index show update) do
      resource :learning, only: %i(show update), controller: "practices/learning"
    end
    resources :reports, only: %i(index)
    namespace "reports" do
      resources :unchecked, only: %i(index)
      resources :recents, only: %i(index)
    end
    resources :watches, only: %i(index)
    namespace "watches" do
      resources :toggle, only: %i(index create destroy)
    end
    resources :memos, only: %i(create update destroy)
    resources :mentor_memos, only: %i(update)
    resources :tags, only: %i(index update)
    resources :pages, only: %i(index update)
    resources :questions, only: %i(index show update)
    resources :followings, only: %i(create update destroy)
    namespace :products do
      resources :unchecked, only: %i(index)
      resources :unassigned, only: %i(index)
      resources :self_assigned, only: %i(index)
      resource :checker, only: %i(update), controller: 'checker'
      resource :passed, only: %i(show), controller: 'passed'
    end
    resources :products, only: %i(index)
    namespace :categories_practices do
      resources :position, only: %i(update)
    end
    resources :announcements, except: %i(new edit)
    resources :searchables, only: %i(index)
    resources :niconico_calendars, only: %i(show)
    resources :bookmarks, only: %i(index create destroy)
    resources :events, only: %i(index)
    resources :report_templates, only: %i(create update)
    resources :markdown_tasks, only: %i(create)
    namespace :talks do
      resources :unreplied, only: %i(index)
    end
    resources :talks, only: %i(index)
  end
end
