# frozen_string_literal: true

class CurrentUser::BookmarksController < ApplicationController
  before_action :require_login
  before_action :set_user

  def index; end

  private

  def set_user
    @user = current_user
  end

  def user
    @user ||= current_user
  end
end
