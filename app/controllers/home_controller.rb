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

        @completed_learnings = current_user.learnings
                                           .includes(:practice)
                                           .where(status: 3)
                                           .order(updated_at: :desc)

        users = User.with_attached_avatar

        @job_seeking_users = users.includes(:course, :works, :products, :reports, :company).job_seeking

        @depressed_reports = User.depressed_reports(users.students_and_trainees)

        @inactive_students_and_trainees = users.inactive_students_and_trainees

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
