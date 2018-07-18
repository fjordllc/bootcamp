class ChecksController < ApplicationController
  include ChecksHelper
  include Gravatarify::Helper
  before_action :require_admin_login, only: [:create]

  def create
    @check = Check.new(
      user: current_user,
      checkable: checkable
    )
    if @check.save
      redirect_to @check.checkable.path, notice: t("checkable_was_successfully_check", 
                                         checkable: checkable.class.model_name.human)
      notify_to_slack(@check)
    else
      render "reports/report"
    end
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
      link = "<#{checkable_url(check)}#check_#{check.id}|#{check.checkable.title}>"

      notify "#{name} check to #{link}",
             username: "#{check.user.login_name} (#{check.user.full_name})",
             icon_url: gravatar_url(check.user, secure: true),
             attachments: [{
               fallback: "check body.",
               text: "#{check.user.login_name}さんが#{check.checkable.title}を確認しました。"
             }]
    end
end
