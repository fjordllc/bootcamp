# frozen_string_literal: true

class API::ChecksController < API::BaseController
  before_action :require_staff_login, only: %i(create destroy)

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
  end

  def destroy
    @check = Check.find(params[:id]).destroy
    head :no_content
  end

  private
    def checkable
      if params[:report_id]
        Report.find(params[:report_id])
      elsif params[:product_id]
        Product.find(params[:product_id])
      end
    end

    def notify_to_slack(check)
      name = "#{check.user.login_name}"
      link = "<#{polymorphic_path(check.checkable)}#check_#{check.id}|#{check.checkable.title}>"

      notify "#{name} check to #{link}",
             username: "#{check.user.login_name} (#{check.user.full_name})",
             icon_url: url_for(check.user.avatar),
             attachments: [{
               fallback: "check body.",
               text: "#{check.user.login_name}さんが#{check.checkable.title}を確認しました。"
             }]
    end
end
