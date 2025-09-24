# frozen_string_literal: true

class CurrentUser::BookmarksController < ApplicationController
  def index
    @user = current_user
  end

  def destroy
    Bookmark.find(params[:id]).destroy

    redirect_to root_path, notice: 'Bookmarkを削除しました。'
  end
end
