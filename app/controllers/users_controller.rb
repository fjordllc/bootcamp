class UsersController < ApplicationController
  include Gravatarify::Helper
  before_action :require_login, only: %w[edit update destroy]
  before_action :set_user, only: %w[show]
  before_action :set_reports, only: %w[show]
  http_basic_authenticate_with name: "intern", password: ENV["INTERN_PASSWORD"] || "test", only: %i(new create)

  def index
    @categories = Category.order("position")
    @users = User.order(updated_at: :desc).page(params[:page]).per(15)
    @target = params[:target] || "all"
    @users =
      case @target
      when "all"
        @users
      when "learning"
        @users.student.select(&:learning_week?)
      when "working"
        @users.student.select(&:working_week?)
      when "graduate"
        @users.graduated
      when "retire"
        @users.retired
      when "adviser"
        @users.advisers
      end
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
      notify "<#{url_for(@user)}|#{@user.full_name} (#{@user.login_name})>が#{User.count}番目の仲間として256INTERNSにJOINしました。",
        username: "#{@user.login_name}@256interns.com",
        icon_url: gravatar_url(@user)
      login(@user.login_name, params[:user][:password], true)
      redirect_to :practices, notice: t('registration_successfull')
    else
      render 'new'
    end
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to @user, notice: "ユーザーを更新しました。"
    else
      render 'edit'
    end
  end

  def destroy
    current_user.destroy
    redirect_to users_url, notice: "ユーザーを削除しました。"
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
        :purpose_cd,
        :find_job_assist,
        :company_id,
        :nda
      )
    end

    def set_user
      @user = User.find(params[:id])
    end

    def set_reports
      @reports = Report.where(user_id: @user.id).order(updated_at: :desc, id: :desc)
    end
end
