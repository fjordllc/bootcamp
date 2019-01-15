# frozen_string_literal: true

class CardController < ApplicationController
  before_action :require_login
  before_action :set_user

  def new
  end

  def edit
  end

  def create
    puts params[:stripeToken]
    redirect_to root_path, notice: "カードを登録しました。"
  end

  def update
    redirect_to root_path, notice: "カードを編集しました。"
  end

  private
    def user_params
      params.require(:user).permit()
    end

    def set_user
      @user = current_user
    end
end
