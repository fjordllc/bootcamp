# frozen_string_literal: true

class CurrentUser::BookmarksController < ApplicationController
  def index
    @user = current_user
  end
end
