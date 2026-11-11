# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: %i[new create show created]
  before_action :prepare_registration_invitation, only: %i[new]
  before_action :require_registration_invitation, only: %i[create]

  PAGER_NUMBER = 24

  def index
    @target = params[:target]
    @target = 'student_and_trainee' unless target_allowlist.include?(@target)
    @entered_tag = params[:tag]
    @watch = params[:watch]

    target_users = TargetUsersQuery.new(
      current_user: current_user,
      target: @target,
      watch: @watch,
      entered_tag: @entered_tag,
      allowed_targets: target_allowlist
    ).call(search_word: params[:search_word])

    @users = target_users
             .page(params[:page]).per(PAGER_NUMBER)
             .preload(:avatar_attachment, :course, :taggings)
             .order(updated_at: :desc)

    @random_tags = User.tags.sample(20)
    @top3_tags_counts = User.tags.limit(3).map(&:count).uniq
    @tag = ActsAsTaggableOn::Tag.find_by(name: params[:tag])
  end

  def show
    @user = User.find_by(id: params[:id]) || User.find_by!(login_name: params[:id])
    @completed_learnings = @user
                           .learnings
                           .includes(:practice)
                           .where(status: 3)
                           .order(updated_at: :desc)

    @calendar = NicoNicoCalendar.new(@user, params[:niconico_calendar])

    @target_end_date = GrassDateParameter.new(params[:end_date]).target_end_date
    @times = Grass.times(@user, @target_end_date)

    reports = @user.reports_with_learning_times
    @study_streak = StudyStreak.new(reports, include_wip: false)

    if logged_in?
      render :show
    else
      render :unauthorized_show, layout: 'not_logged_in'
    end
  end

  def new
    @user = User.new(@registration_invitation&.claims || params.permit(:course_id, :company_id))
    @user.assign_role
  end

  def create
    logger.info "[Signup] 1. start create. #{user_params[:email]}"

    @user = UserRegistrationPreparation.new(
      user_params: user_params,
      registration_invitation: @registration_invitation&.claims,
      credit_card_payment: params[:credit_card_payment]
    ).call

    result = UserRegistration.new(@user, params[:stripeToken], params[:idempotency_token], url_for(@user), session[:affiliate_rd_code]).call

    unless result.success?
      render 'new', locals: { user: @user }
      return
    end

    session.delete(:registration_invitation) if result.free?
    session.delete(:affiliate_rd_code) if !result.free? && session[:affiliate_rd_code].present?

    flash[:x_conversion] = 'signup' unless result.free?
    flash[:signup_email] = @user.email

    redirect_to created_users_path(role: @user.determine_user_role)
  end

  def created
    @role = params[:role] || 'student'
    @email = flash[:signup_email]
  end

  def toggle_show_study_streak
    enabled = params[:toggle].present?
    current_user.update!(show_study_streak: enabled)

    redirect_to url_from(params[:redirect_to]) || root_path
  end

  private

  def target_allowlist
    target_allowlist = %w[student_and_trainee student trainee followings mentor graduate adviser year_end_party]
    target_allowlist.push('job_seeking') if current_user.adviser?
    target_allowlist.concat(%w[job_seeking hibernated retired inactive all]) if current_user.mentor? || current_user.admin?
    target_allowlist
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
      :job_seeker,
      :tag_list, :after_graduation_hope, :feed_url,
      :country_code, :subdivision_code, :invoice_payment,
      :credit_card_payment,
      :referral_source, :other_referral_source,
      authored_books_attributes: %i[id cover title url _destroy]
    )
  end

  def prepare_registration_invitation
    session.delete(:registration_invitation)
    return unless params.key?(:role) || params.key?(:token)

    @registration_invitation = RegistrationInvitation.verify(params[:token])
    return reject_registration_invitation unless @registration_invitation&.matching_invitation_query?(params)

    session[:registration_invitation] = params[:token]
  end

  def require_registration_invitation
    token = session[:registration_invitation]
    @registration_invitation = RegistrationInvitation.verify(token)
    return reject_registration_invitation if token && !@registration_invitation

    @registration_invitation ||= RegistrationInvitation.new({})

    return if !params.key?(:role) && @registration_invitation.matching_invitation_form?(params)

    reject_registration_invitation
  end

  def reject_registration_invitation
    session.delete(:registration_invitation)
    redirect_to root_path, notice: 'アドバイザー・メンター・研修生登録にはTOKENが必要です。'
  end
end
