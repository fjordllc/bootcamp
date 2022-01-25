# frozen_string_literal: true

class Notifications::AllmarksController < ApplicationController
  def create
    current_user.mark_all_as_read_and_delete_cache_of_unreads
    redirect_to notifications_path, notice: '全て既読にしました'
  end
end
