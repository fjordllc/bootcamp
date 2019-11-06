# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :require_login, except: %i(new create)
  before_action :set_user, only: %w(show)

  def index
    @target = params[:target] || "student"
    @users = User.with_attached_avatar
      .preload(:course)
      .order(updated_at: :desc)
      .users_role(@target)
  end

  def show
  end

  def new
    @user = User.new

    case params[:role]
    when "adviser"
      @user.adviser = true
    when "trainee"
      @user.trainee = true
    end
  end

  def create
    @user = User.new(user_params)
    @user.course = Course.first

    if @user.trainee?
      @user.free = true
    end

    if @user.save
      UserMailer.welcome(@user).deliver_now
      notify_to_slack!
    else
      render "new"
    end
  end

  private
    def notify_to_slack!
      SlackNotification.notify "<#{url_for(@user)}|#{@user.full_name} (#{@user.login_name})>が#{User.count}番目の仲間としてBootcampにJOINしました。",
        username: "#{@user.login_name}@bootcamp.fjord.jp",
        icon_url: @user.avatar_url
      redirect_to root_url, notice: "サインアップメールをお送りしました。メールからサインアップを完了させてください。"
    end

    def user_params
      params.require(:user).permit(
        :login_name,
        :first_name,
        :last_name,
        :kana_first_name,
        :kana_last_name,
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
        :prefecture_code,
        :company_id,
        :nda,
        :avatar,
        :trainee,
        :adviser
      )
    end

    def set_user
      @user = User.where(id: params[:id]).or(User.where(login_name: params[:id])).first!
    end
end
