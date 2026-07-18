# frozen_string_literal: true

class HibernatedRetirementController < ApplicationController
  skip_before_action :require_active_user_login, raise: false

  def new
    @user = User.new
  end

  def create
    @user = login(params[:user][:email], params[:user][:password])
    if @user
      if @user&.hibernated?
          retirement = Retirement.by_self(retire_reason_params, user: current_user)
          if retirement.execute
            logout
            redirect_to retirement_url
          else
            current_user.retired_on = nil
            @regular_events_without_finished = RegularEvent.organizer_event(current_user).exclude_finished
            render :new
          end
      else
        @user = User.new
        flash.now[:alert] = '休会していないユーザーです。'
        render 'new'
      end
    else
      @user = User.new
      flash.now[:alert] = 'メールアドレスかパスワードが違います。'
      render 'new'
    end
  end

  private

  def retire_reason_params
    params.require(:user).permit(:retire_reason, :satisfaction, :opinion, retire_reasons: [])
  end

end