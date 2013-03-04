class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to(:users, notice: 'Registration successfull. Check your email for activation instructions.')
    else
      render action: 'new'
    end
  end

  def update
    if @user.update_attributes(user_params)
      redirect_to(@user, notice: 'User was successfully updated.')
    else
      render action: 'edit'
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url
  end

  private
    def user_params
      params.require(:user).permit(
        :login_name,
        :name,
        :email,
        :password,
        :password_cofirmation
      )
    end

    def set_user
      @user = User.find(params[:id])
    end
end
