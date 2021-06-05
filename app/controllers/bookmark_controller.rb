# frozen_string_literal: true

class BookmarksController < ApplicationController
  before_action :require_login

  def index
    @bookmarks = Bookmark.where(user_id: current_user.id).order(created_at: :desc)
  end
end
