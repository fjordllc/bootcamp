# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    if current_user
      if current_user.retired_on?
        logout
        redirect_to retire_path
      else
        if current_user.student? && !current_user.free? && !current_user.paid?
          flash.now[:alert] = "クレジットカードを#{helpers.link_to "登録", new_card_path}してください。".html_safe
        end

        @announcements = Announcement.limit(5).order(created_at: :desc)
        render aciton: :index
      end
    else
      render template: "welcome/index", layout: "welcome"
    end
  end

  def pricing
  end
end
