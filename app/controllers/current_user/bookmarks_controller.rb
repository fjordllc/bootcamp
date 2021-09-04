# frozen_string_literal: true

class CurrentUser::BookmarksController < ApplicationController
  before_action :require_login

  def index
    @user = current_user
  end
end
