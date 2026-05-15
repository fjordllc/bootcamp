# frozen_string_literal: true

class PressReleasesController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: %i[index]

  layout 'lp'

  def index
    @press_releases = Article.press_releases.page(params[:page])
  end
end
