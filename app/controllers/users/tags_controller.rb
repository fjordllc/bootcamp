# frozen_string_literal: true

class Users::TagsController < ApplicationController
  def index
    @tags = User.tags.order('taggings_count desc')
    @top3_tags_counts = @tags.limit(3).map(&:taggings_count).uniq
  end

  def update
    current_user.tag_list.add(params[:tag])
    current_user.save
    redirect_to "/users/tags/#{params[:tag]}"
  end
end
