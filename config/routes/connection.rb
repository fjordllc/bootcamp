# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :connection do
    resource :git_hub, only: %i(destroy), controller: "git_hub"
  end
end
