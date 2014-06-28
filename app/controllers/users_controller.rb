class UsersController < ApplicationController
  before_action :require_login, only: %w[edit update destroy]
  before_action :set_user, only: %w[show]
  http_basic_authenticate_with name: 'intern', password: ENV['INTERN_PASSWORD'] || 'test'

  def index
    @categories = Category.order('position')
    @users = User.in_school.order('updated_at desc')
    @users =
      case params.fetch('target', 'all')
      when 'learning'
        @users.select(&:learning_week?)
      when 'working'
        @users.select {|u| u.working_week? }
      else
        @users
      end
    @active_users = @users.select(&:active?)
    @inactive_users = @users.reject(&:active?)
    @graduated_users = User.graduated.order('updated_at desc')
  end

  def show
  end

  def new
    @user = User.new
    @companies = Company.all
  end

  def edit
    @user = current_user
    @companies = Company.all
  end

  def create
    @user = User.new(user_params)

    if @user.save
      notify("#{@user.full_name}(#{@user.login_name})が256 INTERNSにJoinしました。 #{url_for(@user)}")
      login(@user.login_name, params[:user][:password], true)
      redirect_to :practices, notice: t('registration_successfull')
    else
      render 'new'
    end
  end

  def update
    @user = current_user
    if @user.update(user_params)
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
        :description,
        :twitter_url,
        :facebook_url,
        :blog_url,
        :feed_url,
        :password,
        :password_confirmation,
        :job,
        :purpose,
        :find_job_assist,
        :company_id
      )
    end

    def set_user
      @user = User.find(params[:id])
    end
end
