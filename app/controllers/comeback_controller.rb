# frozen_string_literal: true

class ComebackController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = login(params[:user][:email], params[:user][:password])
    if @user
      if @user&.hibernated?
        @user.comeback!
        redirect_to root_url, notice: '休会から復帰しました。'
      else
        flash.now[:alert] = '休会していないユーザーです。'
        render 'new'
      end
    else
      flash.now[:alert] = 'メールアドレスかパスワードが違います。'
      render 'new'
    end
  end
end
