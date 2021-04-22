# frozen_string_literal: true

class Users::TagsController < ApplicationController
  helper_method :users_tagged_with

  def index
    @tags = ActsAsTaggableOn::Tag
            .joins(:taggings)
            .select('tags.id, tags.name, COUNT(taggings.id) as taggings_count')
            .group('tags.id, tags.name, tags.taggings_count')
            .where(taggings: { taggable_type: 'User' })
            .order('taggings_count desc')
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
