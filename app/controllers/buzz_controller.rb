# frozen_string_literal: true

class BuzzController < ApplicationController
  before_action :set_buzz
  skip_before_action :require_active_user_login, raise: false, only: %i[show]
  before_action :require_admin_or_mentor_login, except: %i[show]

  def show
    render layout: 'welcome'
  end

  def edit; end

  def update
    if @buzz.update(buzz_params)
      redirect_to buzz_path, notice: '紹介・言及記事を更新しました'
    else
      render :edit
    end
  end

  private

  def set_buzz
    @buzz = Buzz.first
  end

  def buzz_params
    params.require(:buzz).permit(:body)
  end
end
