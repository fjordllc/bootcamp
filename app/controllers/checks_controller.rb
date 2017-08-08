class ChecksController < ApplicationController
  include Gravatarify::Helper

  def create
    @report       = Report.find(params[:report_id])
    @check        = Check.new
    @check.user   = current_user
    @check.report = @report
    if @check.save
      redirect_to @report, notice: t("report_was_successfully_check")
      notify_to_slack(@check)
    else
      render "reports/report"
    end
  end

  private

    def set_report
      @report = Report.find(params[:report_id])
    end

  def notify_to_slack(check)
    name = "#{check.user.login_name}"
    link = "<#{report_url(check.report)}#check_#{check.id}|#{check.report.title}>"

    notify "#{name} check to #{link}",
           username:    "#{check.user.login_name} (#{check.user.full_name})",
           icon_url:    gravatar_url(check.user),
           attachments: [{ fallback: "check body.",
                           text:     "#{check.user.login_name}さんが#{check.report.title}を確認しました。"
                         }]
  end
end
