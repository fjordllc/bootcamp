# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    if current_user
      if current_user.retired_on?
        logout
        redirect_to retire_path
      else
        @announcements = Announcement.with_avatar
                                     .where(wip: false)
                                     .order(published_at: :desc)
                                     .limit(5)
        @completed_learnings = current_user.learnings.where(status: 3).order(updated_at: :desc)
        @ordered_inactive_students_and_trainees = User.inactive_students_and_trainees.order(updated_at: :desc)
        set_required_fields
        render aciton: :index
      end
    else
      render template: 'welcome/index', layout: 'welcome'
    end
  end

  def pricing; end

  def test; end

  private

  def set_required_fields
    @required_fields = RequiredField.new(
      description: current_user.description,
      github_account: current_user.github_account,
      discord_account: current_user.discord_account
    )
  end
end
