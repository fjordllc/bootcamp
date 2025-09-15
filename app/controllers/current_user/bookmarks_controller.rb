# frozen_string_literal: true

class CurrentUser::BookmarksController < ApplicationController
  PAGER_NUMBER = 20

  def index
    @user = current_user
    @bookmarks = current_user.bookmarks.includes(:bookmarkable).order(created_at: :desc, id: :desc).page(params[:page]).per(PAGER_NUMBER)
  end
end
