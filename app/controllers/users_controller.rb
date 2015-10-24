class UsersController < ApplicationController
  before_action :require_login, only: %w[edit update destroy]
  before_action :set_user, only: %w[show]
  http_basic_authenticate_with name: 'intern', password: ENV['INTERN_PASSWORD'] || 'test'

  def index
    @categories = Category.order('position')
    @users = User.order(updated_at: :desc)
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
      notify "<#{url_for(@user)}|#{@user.full_name} (#{@user.login_name})>が#{User.count}番目の仲間として256INTERNSにJOINしました。"
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
        :github_account,
        :twitter_url,
        :facebook_url,
        :blog_url,
        :feed_url,
        :password,
        :password_confirmation,
        :job,
        :purpose,
        :find_job_assist,
        :company_id,
        :nda
      )
    end

    def set_user
      @user = User.find(params[:id])
    end
end
