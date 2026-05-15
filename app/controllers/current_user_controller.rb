# frozen_string_literal: true

class CurrentUserController < ApplicationController
  before_action :set_user

  def edit
    @companies = Company.all
  end

  def update
    @user.uploaded_avatar = user_params[:avatar]
    if @user.update(user_params)
      redirect_to @user, notice: 'ユーザー情報を更新しました。'
    else
      render 'edit'
    end
  end

  private

  def user_params
    user_attribute = [
      :adviser, :login_name, :name,
      :name_kana, :email, :course_id,
      :description,
      :github_account, :twitter_account, :facebook_url,
      :blog_url, :password, :password_confirmation,
      :job, :organization, :os,
      { experiences: [] }, :editor, :other_editor, :company_id,
      :nda, :avatar, :trainee,
      :mail_notification, :job_seeker, :tag_list,
      :after_graduation_hope, :training_ends_on, :profile_image,
      :show_mentor_profile,
      :profile_name, :profile_job, :profile_text, { authored_books_attributes: %i[id title url cover _destroy] },
      :feed_url, :country_code, :subdivision_code, { discord_profile_attributes: %i[id account_name times_url] },
      { learning_time_frame_ids: [] }
    ]
    user_attribute.concat(admin_user_attributes) if current_user.admin?
    params.require(:user).permit(user_attribute)
  end

  def set_user
    @user = current_user
  end

  def admin_user_attributes
    %i[
      retired_on graduated_on github_collaborator
      auto_retire invoice_payment mentor subscription_id
    ]
  end
end
