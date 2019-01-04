# frozen_string_literal: true

class UsersController < ApplicationController
  include Gravatarify::Helper
  before_action :require_login, only: %i(index show edit update destroy)
  before_action :set_user, only: %w[show]

  def index
    @categories = Category.order("position")
    @users = User.order(updated_at: :desc)
    @target = params[:target] || "student"
    @users =
      case @target
      when "student"
        @users.students
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
    @user.adviser = params[:role] == "adviser"
    @companies = Company.all
  end

  def edit
    @user = current_user
    @companies = Company.all
  end

  def create
    @user = User.new(user_params)
    @user.company = Company.first
    @user.course = Course.first

    if @user.save
      UserMailer.welcome(@user).deliver_now
      notify "<#{url_for(@user)}|#{@user.full_name} (#{@user.login_name})>が#{User.count}番目の仲間としてBootcampにJOINしました。",
        username: "#{@user.login_name}@bootcamp.fjord.jp",
        icon_url: gravatar_url(@user, secure: true)
      login(@user.login_name, params[:user][:password], true)
      redirect_to root_url, notice: "サインアップしました。"
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
        :adviser,
        :login_name,
        :first_name,
        :last_name,
        :email,
        :course_id,
        :description,
        :slack_account,
        :github_account,
        :twitter_account,
        :facebook_url,
        :blog_url,
        :feed_url,
        :password,
        :password_confirmation,
        :job,
        :organization,
        :os,
        :study_place,
        :experience,
        :how_did_you_know,
        :company_id,
        :nda
        )
    end

    def set_user
      @user = User.find(params[:id])
    end
end
