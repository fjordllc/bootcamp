# frozen_string_literal: true

class RetirementController < ApplicationController
  before_action :require_login, except: %i[show]

  def show; end

  def new; end

  def create
    current_user.assign_attributes(retire_reason_params)
    current_user.retired_on = Date.current
    if current_user.save(context: :retirement)
      UserMailer.retire(current_user).deliver_now
      destroy_subscription
      notify_to_admins
      notify_to_discord
      logout
      redirect_to retirement_url
    else
      render :new
    end
  end

  private

  def retire_reason_params
    params.require(:user).permit(:retire_reason, :satisfaction, :opinion, retire_reasons: [])
  end

  def destroy_subscription
    Subscription.new.destroy(current_user.subscription_id) if current_user.subscription_id
  end

  def notify_to_admins
    User.admins.each do |admin_user|
      Notification.retired(current_user, admin_user)
    end
  end

  def notify_to_discord
    User.retired.find_each do |retired_user|
      if retired_user.retired_on == Date.current.prev_month(n = 3)
      ChatNotifier.message(
      "#{retired_user.login_name} さんが退会して3ヶ月経過しました。
      Discord ID
      #{retired_user.discord_account}
      ユーザーページ
      https://bootcamp.fjord.jp/users/#{retired_user.id}",
    webhook_url: ENV['DISCORD_TEST_WEBHOOK_URL']
    )
      end
    end
  end
end
