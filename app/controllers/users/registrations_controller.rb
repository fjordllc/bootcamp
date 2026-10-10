# frozen_string_literal: true

class Users::RegistrationsController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: %i[new create created]
  before_action :require_token, only: %i[new] if Rails.env.production?

  def new
    @user = User.new
    @user.course_id = params[:course_id]
    @user.company_id = params[:company_id]
    assign_role(@user)

    render 'users/new'
  end

  def create
    logger.info "[Signup] 1. start create. #{user_params[:email]}"

    @user = User.new(user_params)
    @user.course_id = params[:user][:course_id] if params[:user][:course_id].present?
    @user.course_id ||= Course.first.id
    @user.build_discord_profile
    @user.credit_card_payment = params[:credit_card_payment]
    @user.uploaded_avatar = user_params[:avatar]
    @user.unsubscribe_email_token = SecureRandom.urlsafe_base64

    if @user.staff? || @user.trainee?
      create_free_user!
    else
      create_user!
    end
  end

  def created
    @role = params[:role] || 'student'
    @email = flash[:signup_email]

    render 'users/created'
  end

  private

  def create_free_user!
    logger.info "[Signup] 2. start create free user. #{@user.email}"
    if @user.save
      logger.info "[Signup] 3. after save free user. #{@user.email}"
      UserMailer.welcome(@user).deliver_now
      notify_to_mentors(@user)
      notify_to_chat(@user)
      ActiveSupport::Notifications.instrument('student_or_trainee.create', user: @user) if @user.trainee?
      logger.info "[Signup] 4. after create times channel for free user. #{@user.email}"
      flash[:signup_email] = @user.email
      redirect_to created_users_path(role: determine_user_role(@user))
    else
      render 'users/new', locals: { user: @user }
    end
  end

  def create_user!
    registration_succeeded = PaidUserRegistrationService.new(
      user: @user,
      stripe_token: params[:stripeToken],
      idempotency_token: params[:idempotency_token],
      user_url: url_for(@user)
    ).call

    if registration_succeeded
      send_affiliate_kickback(@user)
      notify_to_mentors(@user)
      notify_to_chat(@user)
      flash[:x_conversion] = 'signup'
      flash[:signup_email] = @user.email
      logger.info "[Signup] 8. after create times channel. #{@user.email}"
      redirect_to created_users_path(role: determine_user_role(@user))
    else
      render 'users/new'
    end
  end

  def send_affiliate_kickback(user)
    rd_code = session[:affiliate_rd_code]
    return if rd_code.blank?

    AffiliateKickbackJob.perform_later(user.id, rd_code)
    session.delete(:affiliate_rd_code)
  end

  def notify_to_mentors(user)
    User.mentor.each do |mentor|
      ActivityDelivery.with(sender: user, receiver: mentor, sender_roles: user.roles_to_s).notify(:signed_up)
    end
  end

  def notify_to_chat(user)
    ChatNotifier.message "#{user.login_name}さん#{user.roles_to_s.empty? ? '' : "（#{user.roles_to_s}）"}が新たなメンバーとしてJOINしました🎉\r<#{url_for(user)}>"
  end

  def user_params
    params.require(:user).permit(
      :login_name, :name, :name_kana,
      :email, :course_id, :description,
      :github_account, :twitter_account,
      :facebook_url, :blog_url, :password,
      :password_confirmation, :job, :organization,
      :os, { experiences: [] }, :editor, :other_editor,
      :company_id, :nda, :avatar,
      :trainee, :adviser, :mentor, :job_seeker,
      :tag_list, :after_graduation_hope, :feed_url,
      :country_code, :subdivision_code, :invoice_payment,
      :credit_card_payment, :role,
      :referral_source, :other_referral_source,
      authored_books_attributes: %i[id cover title url _destroy]
    )
  end

  def assign_role(user)
    user.role = params[:role]

    case user.role
    when 'adviser'
      user.adviser = true
    when 'trainee_invoice_payment', 'trainee_credit_card_payment', 'trainee_select_a_payment_method'
      user.trainee = true
    when 'mentor'
      user.mentor = true
    end
  end

  def determine_user_role(user)
    if user.adviser?
      'adviser'
    elsif user.trainee?
      'trainee'
    elsif user.mentor?
      'mentor'
    else
      'student'
    end
  end

  def require_token
    return unless params[:role]
    return unless !params[:token] || !ENV['TOKEN'] || params[:token] != ENV['TOKEN']

    redirect_to root_path, notice: 'アドバイザー・メンター・研修生登録にはTOKENが必要です。'
  end
end
