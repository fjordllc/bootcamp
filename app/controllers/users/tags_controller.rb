# frozen_string_literal: true

class Users::TagsController < ApplicationController
  def update
    current_user.tag_list.add(params[:tag])
    current_user.save
    redirect_to "/users/tags/#{params[:tag]}"
  end
end
