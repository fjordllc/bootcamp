# frozen_string_literal: true

class Admin::UsersController < AdminController # rubocop:disable Metrics/ClassLength
  before_action :set_user, only: %i[show edit update]
  ALLOWED_TARGETS = %w[all student_and_trainee inactive hibernated retired graduate adviser mentor trainee year_end_party campaign].freeze

  def index
    @direction = params[:direction] || 'desc'
    @target = params[:target]
    user_scope = User.users_role(@target, allowed_targets: ALLOWED_TARGETS, default_target: 'all')
    user_scope = if @target == 'retired'
                   user_scope.where.not(retired_on: nil)
                 else
                   user_scope.where(retired_on: nil)
                 end
    @job = params[:job]
    user_scope = user_scope.users_job(@job) if @job.present?
    job_seeking = params[:job_seeking]
    user_scope = apply_job_seeking_filter(user_scope, job_seeking)
    payment_method = params[:payment_method]
    user_scope = apply_payment_method_filter(user_scope, payment_method)
    @users = user_scope.with_attached_avatar
                       .preload(:company, :course)
                       .order_by_counts(params[:order_by] || 'id', @direction)
    @emails = user_scope.pluck(:email)
  end

  def show
    render action: :show, layout: nil
  end

  def edit; end

  def update
    @user.diploma_file = nil if params[:user][:remove_diploma] == '1'
    if @user.update(user_params)
      complete_graduation_or_retirement(@user)
      redirect_to user_url(@user), notice: 'ユーザー情報を更新しました。'
    else
      render :edit
    end
  end

  def destroy
    # 今後本人退会時に処理が増えることを想定し、自分自身は削除できないよう
    # 制限をかけておく
    redirect_to admin_users_url, alert: '自分自身を削除する場合、退会から処理を行ってください。' if current_user.id == params[:id]
    user = User.find(params[:id])
    ActiveSupport::Notifications.instrument('learning.destroy', user:)
    user.destroy
    redirect_to admin_users_url, notice: "#{user.name} さんを削除しました。"
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def apply_job_seeking_filter(scope, job_seeking)
    case job_seeking
    when 'true'
      scope.where(job_seeker: true)
    when 'false'
      scope.where(job_seeker: false)
    else
      scope
    end
  end

  def apply_payment_method_filter(scope, payment_method)
    case payment_method
    when 'card'
      scope.where(trainee: true, invoice_payment: false)
    when 'invoice'
      scope.where(trainee: true, invoice_payment: true)
    else
      scope
    end
  end

  def user_params
    params.require(:user).permit(
      :adviser, :login_name, :name,
      :name_kana, :email, :course_id, :subscription_id,
      :description, :github_account,
      :twitter_account, :facebook_url, :blog_url,
      :password, :password_confirmation, :job,
      :organization, :os, :study_place,
      { experiences: [] }, :company_id,
      :trainee, :nda, :avatar,
      :graduated_on, :retired_on,
      :job_seeker, :github_collaborator,
      :officekey_permission, :tag_list, :training_ends_on,
      :profile_image, :profile_name, :profile_job, :mentor, :diploma_file,
      :career_path, :career_memo,
      :auto_retire, :invoice_payment, :show_mentor_profile,
      :profile_text, { authored_books_attributes: %i[id title url cover _destroy] },
      :country_code, :subdivision_code, discord_profile_attributes: %i[account_name times_url times_id], practice_ids: []
    )
  end

  def complete_graduation_or_retirement(user)
    if user.saved_change_to_retired_on? &&
       user.retired_on_before_last_save.nil?
      AfterUserRetirement.new(user, triggered_by: 'admin').call

      return
    end

    if user.saved_change_to_graduated_on? &&
       user.graduated_on_before_last_save.nil?
      destroy_subscription(user)
    end
  end

  def destroy_subscription(user)
    return if user.subscription_id.blank?

    Subscription.new.destroy(user.subscription_id)
  end
end
