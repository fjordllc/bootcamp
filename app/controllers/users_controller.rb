# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :require_login, except: %i(new create)
  before_action :set_user, only: %w(show)

  def index
    @categories = Category.order("position")
    @users = User.order(updated_at: :desc)
    @target = params[:target] || "student"
    @users = @users.users_role(@target)
  end

  def show
  end

  def new
    @user = User.new
    @user.adviser = params[:role] == "adviser"
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
        icon_url: url_for(@user.avatar)
      login(@user.login_name, params[:user][:password], true)
      redirect_to root_url, notice: "サインアップしました。"
    else
      render "new"
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.assign_attributes(retire_reason_params)
    @user.retired_on = Date.current
    if @user.save(context: :retire_reason_presence)
      UserDeleter.new(current_user).delete
      redirect_to login_url, notice: "退会しました。"
    else
      render "users/retirements/index"
    end
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
        :nda,
        :graduated_on,
        :retired_on,
        :free,
        :avatar
      )
    end

    def set_user
      @user = User.find(params[:id])
    end

    def retire_reason_params
      params.require(:user).permit(:retire_reason)
    end
end
