# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: %i[new create show]
  before_action :require_token, only: %i[new] if Rails.env.production?
  before_action :set_user, only: %w[show]

  PAGER_NUMBER = 20

  def index
    @target = params[:target]
    @target = 'student_and_trainee' unless target_allowlist.include?(@target)
    @watch = params[:watch]

    target_users =
      if @target == 'followings'
        current_user.followees_list(watch: @watch)
      elsif params[:tag]
        User.tagged_with(params[:tag])
      else
        users = User.users_role(@target, allowed_targets: target_allowlist)
        @target == 'inactive' ? users.order(:last_activity_at) : users
      end

    @users = target_users
             .page(params[:page]).per(PAGER_NUMBER)
             .preload(:avatar_attachment, :course, :taggings)
             .order(updated_at: :desc)

    @users = @users.unhibernated.unretired unless @target.in? %w[hibernated retired]

    @random_tags = User.tags.sample(20)
    @top3_tags_counts = User.tags.limit(3).map(&:count).uniq
    @tag = ActsAsTaggableOn::Tag.find_by(name: params[:tag])
  end

  def show
    @completed_learnings = @user
                           .learnings
                           .includes(:practice)
                           .where(status: 3)
                           .order(updated_at: :desc)

    if logged_in?
      render :show
    else
      render :unauthorized_show, layout: 'not_logged_in'
    end
  end

  def new
    @user = User.new
    case params[:role]
    when 'adviser'
      @user.adviser = true
    when 'trainee'
      @user.trainee = true
    end
    @user.course_id = params[:course_id]
    @user.company_id = params[:company_id]
  end

  def create
    logger.info "[Signup] 1. start create. #{user_params[:email]}"

    @user = User.new(user_params)
    @user.course_id ||= Course.first.id
    @user.free = true if @user.trainee?
    @user.build_discord_profile
    Newspaper.publish(:user_create, { user: @user })
    if @user.staff? || @user.trainee?
      create_free_user!
    else
      create_user!
    end
  end

  private

  def target_allowlist
    target_allowlist = %w[student_and_trainee followings mentor graduate adviser trainee year_end_party]
    target_allowlist.push('job_seeking') if current_user.adviser?
    target_allowlist.concat(%w[job_seeking hibernated retired inactive all]) if current_user.mentor? || current_user.admin?
    target_allowlist
  end

  def create_free_user!
    logger.info "[Signup] 2. start create free user. #{@user.email}"
    if @user.save
      logger.info "[Signup] 3. after save free user. #{@user.email}"
      UserMailer.welcome(@user).deliver_now
      notify_to_mentors(@user)
      notify_to_chat(@user)
      Newspaper.publish(:student_or_trainee_create, { user: @user }) if @user.trainee?
      logger.info "[Signup] 4. after create times channel for free user. #{@user.email}"
      redirect_to root_url, notice: 'サインアップメールをお送りしました。メールからサインアップを完了させてください。'
    else
      render 'new'
    end
  end

  # rubocop:disable Metrics/MethodLength, Metrics/BlockLength
  def create_user!
    logger.info "[Signup] 2. start create user. #{@user.email}"
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

      logger.info "[Signup] 3. before create subscription. #{@user.email}"
      begin
        customer = Card.new.create(@user, params[:stripeToken], token)
        subscription = Subscription.new.create(customer['id'], "#{token}-subscription")
      rescue Stripe::CardError => e
        logger.error "[Payment] customerの作成時にエラーが発生しました: #{e.message}"
        @user.errors.add :base, I18n.translate("stripe.errors.#{e.code}")
        render 'new'
        return false
      end
      logger.info "[Signup] 4. after create subscription.#{@user.email}"

      @user.customer_id = customer['id']
      @user.subscription_id = subscription['id']

      if @user.save
        logger.info "[Signup] 5. after save user. #{@user.email}"
        UserMailer.welcome(@user).deliver_now
        notify_to_mentors(@user)
        notify_to_chat(@user)
        Newspaper.publish(:student_or_trainee_create, { user: @user }) if @user.student?
        logger.info "[Signup] 8. after create times channel. #{@user.email}"
        redirect_to root_url, notice: 'サインアップメールをお送りしました。メールからサインアップを完了させてください。'
      else
        render 'new'
      end
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/BlockLength

  def notify_to_mentors(user)
    User.mentor.each do |mentor|
      ActivityDelivery.with(sender: user, receiver: mentor, sender_roles: user.roles_to_s).notify(:signed_up)
    end
  end

  def notify_to_chat(user)
    ChatNotifier.message "#{user.login_name}さんが新たなメンバーとしてJOINしました🎉\r#{url_for(user)}"
  end

  def user_params
    params.require(:user).permit(
      :login_name, :name, :name_kana,
      :email, :course_id, :description,
      :github_account, :twitter_account,
      :facebook_url, :blog_url, :password,
      :password_confirmation, :job, :organization,
      :os, :experience, :editor,
      :company_id, :nda, :avatar,
      :trainee, :adviser, :job_seeker,
      :tag_list, :after_graduation_hope, :feed_url,
      :country_code, :subdivision_code
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
