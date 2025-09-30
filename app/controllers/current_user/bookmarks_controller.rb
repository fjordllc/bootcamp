# frozen_string_literal: true

class CurrentUser::BookmarksController < ApplicationController
  PAGER_NUMBER = 20

  before_action :set_bookmarks, only: [:index]

  def index; end

  def destroy
    current_user.bookmarks.find(params[:id]).destroy
    set_bookmarks
    render partial: 'current_user/bookmarks/list'
  end

  private

  def set_bookmarks
    @bookmarks = current_user.bookmarks.includes(bookmarkable: :user).order(created_at: :desc, id: :desc).page(params[:page]).per(PAGER_NUMBER)
  end
end
