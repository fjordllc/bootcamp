# frozen_string_literal: true

class ChecksController < ApplicationController
  include Rails.application.routes.url_helpers
  include Gravatarify::Helper
  before_action :require_admin_adviser_or_mentor_login, only: [:create]

  def create
    @check = Check.new(
      user: current_user,
      checkable: checkable
    )

    @check.save!
    notify_to_slack(@check)
    redirect_back fallback_location: root_path,
      notice: "#{checkable.class.model_name.human}を確認しました。"
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
             icon_url: gravatar_url(check.user, secure: true),
             attachments: [{
               fallback: "check body.",
               text: "#{check.user.login_name}さんが#{check.checkable.title}を確認しました。"
             }]
    end
end
