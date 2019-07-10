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
    user_register = UserRegister.new(User.new)
    @user = user_register.create(user_params)
    if @user.errors.present?
      UserMailer.welcome(@user).deliver_now
      notify_to_slack
      redirect_to root_url, notice: "サインアップメールをお送りしました。メールからサインアップを完了させてください。"
    else
      render "new"
    end
  end

  private
    def notify_to_slack
      SlackNotification.notify "<#{url_for(@user)}|#{@user.full_name} (#{@user.login_name})>が#{User.count}番目の仲間としてBootcampにJOINしました。",
        username: "#{@user.login_name}@bootcamp.fjord.jp",
        icon_url: url_for(@user.avatar)
    end

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
        :company_id,
        :nda,
        :graduated_on,
        :retired_on,
        :free,
        :avatar,
        :trainee
      )
    end

    def set_user
      @user = User.where(id: params[:id]).or(User.where(login_name: params[:id])).first!
    end
end
