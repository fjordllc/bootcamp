# frozen_string_literal: true

class CurrentUserController < ApplicationController
  before_action :set_user

  def edit
    @companies = Company.all
  end

  def update
    if @user.update(user_params)
      @user.rename_avatar_and_strip_exif if user_params[:avatar]
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
      :description, :job_seeking, :discord_account,
      :github_account, :twitter_account, :facebook_url,
      :blog_url, :times_url, :password, :password_confirmation,
      :job, :organization, :os,
      :experience, :prefecture_code, :company_id,
      :nda, :avatar, :trainee,
      :mail_notification, :job_seeker, :tag_list,
      :after_graduation_hope, :training_ends_on, :profile_image,
      :profile_name, :profile_job, :profile_text, { authored_books_attributes: %i[id title url cover _destroy] },
      :feed_url, :country_code, :subdivision_code
    ]
    user_attribute.push(:retired_on, :graduated_on, :free, :github_collaborator) if current_user.admin?
    params.require(:user).permit(user_attribute)
  end

  def set_user
    @user = current_user
  end
end
