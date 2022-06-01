# frozen_string_literal: true

class API::BaseController < ApplicationController
  before_action :require_login_for_api, unless: :is_before_articles_contoroller?

  def is_before_articles_contoroller?
    Rails.application.routes.recognize_path(request.referer)[:controller] == 'articles'
  end
end
