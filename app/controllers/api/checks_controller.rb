# frozen_string_literal: true

class API::ChecksController < API::BaseController
  before_action :require_staff_login_for_api, only: %i(create destroy)

  def index
    @checks = Check.where(
      checkable: checkable
    )
  end

  def create
    @check = Check.new(
      user: current_user,
      checkable: checkable
    )

    @check.save!
    notify_to_slack(@check)
    head :created
  end

  def destroy
    @check = Check.find(params[:id]).destroy
    head :no_content
  end

  private
    def checkable
      params[:checkable_type].constantize.find_by(id: params[:checkable_id])
    end

    def notify_to_slack(check)
      name = "#{check.user.login_name}"
      link = "<#{polymorphic_path(check.checkable)}#check_#{check.id}|#{check.checkable.title}>"

      SlackNotification.notify "#{name} check to #{link}",
                               username: "#{check.user.login_name} (#{check.user.name})",
                               icon_url: check.user.avatar_url,
                               attachments: [{
                                 fallback: "check body.",
                                 text: "#{check.user.login_name}さんが#{check.checkable.title}を確認しました。"
                               }]
    end
end
