class UserSessionsController < ApplicationController
  def new
  end

  def create
    if @user = login(params[:user][:login_name], params[:user][:password], true)
      redirect_back_or_to :users, notice: t('sign_in_successful')
    else
      flash.now[:alert] = t('invalid_email_or_password')
      render action: 'new'
    end
  end

  def destroy
    logout
    redirect_to :users, notice: t('sign_out')
  end
end
