# frozen_string_literal: true

class CurrentUser::BookmarksController < ApplicationController
  PAGER_NUMBER = 20

  before_action :set_bookmarks, only: [:index]

  def index; end

  def destroy
    current_user.bookmarks.find(params[:id]).destroy
    head :no_content
  end

  private

  def set_bookmarks
    @bookmarks = current_user.bookmarks.preload(bookmarkable: :user).order(created_at: :desc, id: :desc).page(params[:page]).per(PAGER_NUMBER)
  end

  def destroy
    Bookmark.find(params[:id]).destroy

    redirect_to root_path, notice: 'Bookmarkを削除しました。'
  end
end
