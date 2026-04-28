# frozen_string_literal: true

class CurrentUser::BookmarksController < ApplicationController
  PAGER_NUMBER = 20

  before_action :set_bookmarks, only: [:index]

  def index; end

  def dashboard
    bookmarks = current_user.bookmarks.order(created_at: :desc).limit(5)
    count = current_user.bookmarks.count

    if count.zero?
      head :ok
    else
      render DashboardBookmarksComponent.new(bookmarks:, count:), layout: false
    end
  end

  def destroy
    current_user.bookmarks.find(params[:id]).destroy
    head :no_content
  end

  private

  def set_bookmarks
    @bookmarks = current_user.bookmarks.preload(bookmarkable: :user).order(created_at: :desc, id: :desc).page(params[:page]).per(PAGER_NUMBER)
  end
end
