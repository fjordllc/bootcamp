# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :scheduler do
    resource :statistic, only: %i(show), controller: "statistic"
    resource :link_checker, only: %i(show), controller: "link_checker"
    resource :validator, only: %i(show), controller: "validator"
    resource :daily, only: %i(show), controller: "daily"
    namespace :daily do
      resource :after_retirement, only: %i(show), controller: "after_retirement"
      resource :notify_tomorrow_regular_event, only: %i(show), controller: "notify_tomorrow_regular_event"
    end
  end
end
