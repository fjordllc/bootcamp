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
          set_current_user_practice
          render :new
        end
      else
        flash_message('休会していないユーザーです。')
      end
    else
      flash_message('メールアドレスかパスワードが違います。')
    end
  end

  private

  def flash_message(message)
    @user = User.new
    flash.now[:alert] = message
    render 'new'
  end

  def retire_reason_params
    params.require(:user).permit(:retire_reason, :satisfaction, :opinion, retire_reasons: [])
  end
end
