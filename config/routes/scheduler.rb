# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :scheduler do
    resource :statistic, only: %i(show), controller: "statistic"
    resource :link_checker, only: %i(show), controller: "link_checker"
    resource :retirement_notice, only: %i(show), controller: "retirement_notice"
  end
end
