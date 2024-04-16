# frozen_string_literal: true

class Admin::UsersController < AdminController
  before_action :set_user, only: %i[show edit update]
  ALLOWED_TARGETS = %w[all student_and_trainee inactive hibernated retired graduate adviser mentor trainee year_end_party campaign].freeze

  def index
    @direction = params[:direction] || 'desc'
    @target = params[:target]
    user_scope = User.users_role(@target, allowed_targets: ALLOWED_TARGETS, default_target: 'student_and_trainee')
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
    is_admin_editing_other_user = current_user.admin? && current_user != @user

    @user.assign_attributes(user_params)

    if @user.save(context: is_admin_editing_other_user ? :admin_user_edit : nil)
      destroy_subscription(@user)
      Newspaper.publish(:retirement_create, { user: @user }) if @user.saved_change_to_retired_on?
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
    Newspaper.publish(:learning_destroy, { user: })
    user.destroy
    redirect_to admin_users_url, notice: "#{user.name} さんを削除しました。"
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :adviser, :login_name, :name,
      :name_kana, :email, :course_id, :subscription_id,
      :description, :github_account,
      :twitter_account, :facebook_url, :blog_url,
      :password, :password_confirmation, :job,
      :organization, :os, :study_place,
      :experience, :company_id,
      :trainee, :job_seeking, :nda,
      :graduated_on, :retired_on, :free,
      :job_seeker, :github_collaborator,
      :officekey_permission, :tag_list, :training_ends_on,
      :auto_retire, :invoice_payment,
      :profile_image, :profile_name, :profile_job, :mentor,
      :profile_text, { authored_books_attributes: %i[id title url cover _destroy] },
      :country_code, :subdivision_code, discord_profile_attributes: %i[account_name times_url times_id]
    )
  end

  def destroy_subscription(user)
    return if user.subscription_id.blank?
    return unless user.saved_change_to_retired_on? || user.saved_change_to_graduated_on?

    Subscription.new.destroy(user.subscription_id)
  end
end
