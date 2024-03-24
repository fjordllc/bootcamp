# frozen_string_literal: true

class GithubAuthentication
  include Rails.application.routes.url_helpers

  def initialize(user, auth)
    @user = user
    @auth = auth
  end

  def authenticate
    if @user.blank?
      user = User.find_by(github_id: @auth[:uid])
      if user.blank?
        { path: root_url, alert: 'ログインに失敗しました。先にアカウントを作成後、GitHub連携を行ってください。' }
      elsif user.retired_on?
        { path: retirement_path }
      else
        { path: root_url, notice: 'サインインしました。', user_id: user.id }
      end
    else
      link if @user.github_id.blank?
      { path: root_path, notice: 'GitHubと連携しました。' }
    end
  rescue StandardError => e
    Rails.logger.warn "[GitHub Login] ログインに失敗しました。：#{e.message}"
    { path: root_path, alert: 'GitHubログインに失敗しました。数回試しても続く場合、管理者に連絡してください。' }
  end

  private

  def link
    @user.github_account = @auth[:info][:nickname]
    @user.github_id = @auth[:uid]
    @user.save!
  end
end
