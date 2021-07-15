# frozen_string_literal: true

class Users::TagsController < ApplicationController
  before_action :require_login

  def index
    @tags = User.tags.order('taggings_count desc')
    @top3_tags_counts = @tags.limit(3).map(&:taggings_count).uniq
  end

  def update
    current_user.tag_list.add(params[:tag])
    current_user.save
    url = URI.encode_www_form_component(params[:tag])
    redirect_to "/users/tags/#{url}"
  end

  def destroy
    current_user.tag_list.delete(params[:tag])
    current_user.save
    url = URI.encode_www_form_component(params[:tag])
    redirect_to "/users/tags/#{url}"
  end
end
