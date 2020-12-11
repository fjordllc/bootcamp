# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :require_login, except: %i[new create]
  before_action :require_token, only: %i[new] if Rails.env.production?
  before_action :set_user, only: %w[show]
  PAGER_NUMBER = 20

  def index
    target_allowlist = %w[student_and_trainee followings mentor graduate adviser trainee year_end_party]
    target_allowlist.push('job_seeking') if current_user.adviser?
    target_allowlist.concat(%w[job_seeking retired inactive all]) if current_user.mentor? || current_user.admin?
    @target = params[:target]
    @target = 'student_and_trainee' unless target_allowlist.include?(@target)

    if @target == 'followings'
      followings = Following.where(follower_id: current_user.id).select('followed_id')
      @users = User
               .page(params[:page]).per(PAGER_NUMBER)
               .includes(:company, :avatar_attachment, :course)
               .where(id: followings)
               .order(updated_at: :desc)
    else
      @users = User
               .page(params[:page]).per(PAGER_NUMBER)
               .with_attached_avatar
               .preload(:course)
               .order(updated_at: :desc)
               .users_role(@target)
    end
  end

  def show
    @completed_learnings = @user.learnings.where(status: 3).order(updated_at: :desc)
  end

  def new
    @user = User.new
    case params[:role]
    when 'adviser'
      @user.adviser = true
    when 'trainee'
      @user.trainee = true
    end
    @user.company_id = params[:company_id]
  end

  def create
    @user = User.new(user_params)
    @user.course = Course.first

    @user.free = true if @user.trainee?

    if @user.staff? || @user.trainee?
      create_free_user!
    else
      create_user!
    end

    return unless @user.errors.empty?

    @user.resize_avatar!
  end

  private

  def create_free_user!
    if @user.save
      UserMailer.welcome(@user).deliver_now
      notify_to_slack!
    else
      render 'new'
    end
  end

  # rubocop:disable Metrics/MethodLength, Metrics/BlockLength
  def create_user!
    @user.with_lock do
      unless @user.validate
        render 'new'
        return false
      end

      if Card.new.search(email: @user.email)
        logger.error '[Payment] 同じメールアドレスの顧客が既に登録済みです。'
        @user.errors.add :base, '同じメールアドレスの顧客が既に登録済みです。'
        render 'new'
        return false
      end

      token = params[:idempotency_token]

      begin
        customer = Card.new.create(@user, params[:stripeToken], token)
        subscription = Subscription.new.create(customer['id'], "#{token}-subscription")
      rescue Stripe::CardError => e
        logger.error "[Payment] customerの作成時にエラーが発生しました: #{e.message}"
        @user.errors.add :base, I18n.translate("stripe.errors.#{e.code}")
        render 'new'
        return false
      end

      @user.customer_id = customer['id']
      @user.subscription_id = subscription['id']

      if @user.save
        UserMailer.welcome(@user).deliver_now
        notify_to_slack!
      else
        render 'new'
      end
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/BlockLength

  def notify_to_slack!
    SlackNotification.notify "<#{url_for(@user)}|#{@user.name} (#{@user.login_name})>が#{User.count}番目の仲間としてBootcampにJOINしました。",
                             username: "#{@user.login_name}@bootcamp.fjord.jp",
                             icon_url: @user.avatar_url,
                             channel: '#fjord'
    redirect_to root_url, notice: 'サインアップメールをお送りしました。メールからサインアップを完了させてください。'
  end

  def user_params
    params.require(:user).permit(
      :login_name, :name, :name_kana,
      :email, :course_id, :description,
      :slack_account, :github_account, :twitter_account,
      :facebook_url, :blog_url, :password,
      :password_confirmation, :job, :organization,
      :os, :experience, :prefecture_code,
      :company_id, :nda, :avatar,
      :trainee, :adviser, :job_seeker
    )
  end

  def set_user
    @user = User.where(id: params[:id]).or(User.where(login_name: params[:id])).first!
  end

  def require_token
    return unless params[:role]
    return unless !params[:token] || !ENV['TOKEN'] || params[:token] != ENV['TOKEN']

    redirect_to root_path, notice: 'アドバイザー・メンター・研修生登録にはTOKENが必要です。'
  end
end
