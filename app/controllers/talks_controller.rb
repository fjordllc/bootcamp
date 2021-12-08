# frozen_string_literal: true

class TalksController < ApplicationController
  before_action :require_admin_login, only: %i[index]

  def index; end

  def show
    @talk = Talk.find(params[:id])
    @user = current_user.admin? ? @talk.user : current_user

    return if current_user.admin? || @talk.user == current_user

    redirect_to talk_path(current_user.talk)
  end
end
