# frozen_string_literal: true

class RetirementController < ApplicationController
  skip_before_action :require_login, raise: false, only: %i[show]

  def show; end

  def new; end

  def create
    current_user.assign_attributes(retire_reason_params)
    current_user.retired_on = Date.current
    if current_user.save(context: :retirement)
      user = current_user
      begin
        UserMailer.retire(user).deliver_now
      rescue Postmark::InactiveRecipientError => e
        logger.warn "[Postmark] 受信者由来のエラーのためメールを送信できませんでした。：#{e.message}"
      end

      destroy_subscription
      notify_to_admins
      notify_to_mentors
      logout
      kick_from_discord(user)
      redirect_to retirement_url
    else
      current_user.retired_on = nil
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
      NotificationFacade.retired(current_user, admin_user)
    end
  end

  def notify_to_mentors
    User.mentor.each do |mentor_user|
      NotificationFacade.retired(current_user, mentor_user)
    end
  end

  def kick_from_discord(user)
    discord_account = user.discord_account
    return if discord_account.blank?

    discord_member = DiscordMember.find_by(account_name: discord_account)
    unless discord_member
      logger.warn "[Discord API] #{discord_account} はアカウントが見つかりませんでした。"
      return
    end

    if discord_member.destroy
      logger.info "[Discord API] #{discord_account} を退出させました。"
    else
      logger.error "[Discord API] #{discord_account} は退出できませんでした。"
    end
  end
end
