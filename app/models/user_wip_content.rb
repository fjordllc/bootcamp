# frozen_string_literal: true

class UserWipContent
  def initialize(user)
    @user = user
  end

  def wip_exists?
    @user.pages.wip.exists? || @user.reports.wip.exists? || @user.questions.wip.exists? ||
      @user.products.wip.exists? || @user.announcements.wip.exists? || @user.events.wip.exists?
  end
end
