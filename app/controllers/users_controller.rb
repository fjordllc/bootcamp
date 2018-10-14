# frozen_string_literal: true

class UsersController < ApplicationController
  include Gravatarify::Helper
  before_action :require_login, only: %i(index show edit update destroy)
  before_action :set_user, only: %w[show]
  http_basic_authenticate_with name: "intern", password: ENV["BOOTCAMP_PASSWORD"], only: %i(new create) if Rails.env.production? || Rails.env.staging?

  def index
    @categories = Category.order("position")
    @users = User.order(updated_at: :desc)
    @target = params[:target] || "student"
    @users =
      case @target
      when "student"
        @users.student
      when "graduate"
        @users.graduated
      when "adviser"
        @users.advisers
      when "mentor"
        @users.mentor
      when "all"
        @users
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
      notify "<#{url_for(@user)}|#{@user.full_name} (#{@user.login_name})>が#{User.count}番目の仲間としてBootcampにJOINしました。",
        username: "#{@user.login_name}@bootcamp.fjord.jp",
        icon_url: gravatar_url(@user, secure: true)
      login(@user.login_name, params[:user][:password], true)
      redirect_to :practices, notice: t("registration_successfull")
    else
      render "new"
    end
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to @user, notice: "ユーザーを更新しました。"
    else
      render "edit"
    end
  end

  def destroy
    UserDeleter.new(current_user).delete
    redirect_to users_url, notice: "退会しました。"
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
        :twitter_account,
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
end
