# frozen_string_literal: true

class Users::TagsController < ApplicationController
  helper_method :users_tagged_with

  def index
    @tags = User.tags.order('taggings_count desc')
    @max_counts = @tags.limit(3).map(&:taggings_count).uniq
  end

  def update
    current_user.tag_list.add(params[:tag])
    current_user.save
    redirect_to "/users/tags/#{params[:tag]}"
  end

  private

  def users_tagged_with(tag_name)
    User.with_attached_avatar
        .unretired
        .order(updated_at: :desc)
        .tagged_with(tag_name)
  end
end
