# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :scheduler do
    resource :statistic, only: %i(show), controller: "statistic"
    resource :link_checker, only: %i(show), controller: "link_checker"
    resource :validator, only: %i(show), controller: "validator"
    namespace :daily do
      resource :notify_coming_soon_regular_events, only: %i(show), controller: "notify_coming_soon_regular_events"
      resource :notify_certain_period_passed_after_last_answer, only: %i(show), controller: "notify_certain_period_passed_after_last_answer"
      resource :notify_product_review_not_completed, only: %i(show), controller: "notify_product_review_not_completed"
      resource :send_message, only: %i(show), controller: "send_message"
      resource :auto_retire, only: %i(show), controller: "auto_retire"
      resource :fetch_external_entry, only: %i(show), controller: "fetch_external_entry"
    end
  end
end
