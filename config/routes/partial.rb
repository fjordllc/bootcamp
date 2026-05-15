# frozen_string_literal: true

Rails.application.routes.draw do
  namespace "partial" do
    resource :git_hub_grass, only: %i(show), controller: "git_hub_grass"
  end
end
