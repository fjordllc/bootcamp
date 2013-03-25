class UsersController < ApplicationController
  before_action :require_login, except: %w(index show)
  before_action :set_user, only: %w(show)
  http_basic_authenticate_with name: 'intern', password: ENV['INTERN_PASSWORD'] || 'test'

  def index
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
    @user = current_user
  end

  def create
    @user = User.new(user_params)

    if @user.save
      login(@user.login_name, @user.password, true)
      redirect_to :practices, notice: t('registration_successfull')
    else
      render 'new'
    end
  end

  def update
    @user = current_user
    if @user.update_attributes(user_params)
      redirect_to @user, notice: t('user_was_successfully_updated')
    else
      render 'edit'
    end
  end

  def destroy
    current_user.destroy
    redirect_to users_url, notice: t('user_was_successfully_deleted')
  end

  private
    def user_params
      params.require(:user).permit(
        :login_name,
        :first_name,
        :last_name,
        :email,
        :twitter_url,
        :facebook_url,
        :blog_url,
        :password,
        :password_cofirmation,
        :job
      )
    end

    def set_user
      @user = User.find(params[:id])
    end
end
