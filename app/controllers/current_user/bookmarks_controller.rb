# frozen_string_literal: true

class CurrentUser::BookmarksController < ApplicationController
  PAGER_NUMBER = 20

  def index
    @bookmarks = current_user.bookmarks.includes(bookmarkable: :user).order(created_at: :desc, id: :desc).page(params[:page]).per(PAGER_NUMBER)
  end

  def destroy
    current_user.bookmarks.find(params[:id]).destroy
    head :no_content
  end
end
