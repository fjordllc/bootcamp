# frozen_string_literal: true

class Users::TalkController < ApplicationController
  def show
    @user = User.find(params[:user_id])
  end
end
