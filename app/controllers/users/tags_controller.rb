# frozen_string_literal: true

class Users::TagsController < ApplicationController
  before_action :require_login

  def index
    @tags = User.tags.page(params[:page])
    @top3_tags_counts = User.tags.limit(3).map(&:count).uniq
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
