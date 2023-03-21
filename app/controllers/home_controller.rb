# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :require_active_user_login, raise: false

  def index
    if current_user
      display_dashboard
      display_events_on_dashboard
      display_regular_events_on_dashboard
      display_welcome_message_for_adviser
      set_required_fields
      render aciton: :index
    else
      @mentors = User.with_attached_profile_image.mentor.includes(authored_books: { cover_attachment: :blob })
      render template: 'welcome/index', layout: 'welcome'
    end
  end

  def pricing; end

  def test
    render :test, layout: false
  end

  private

  def set_required_fields
    @required_fields = RequiredField.new(
      avatar_attached: current_user.avatar.attached?,
      tag_list_count: current_user.tag_list.size,
      after_graduation_hope: current_user.after_graduation_hope,
      discord_account: current_user.discord_account,
      github_account: current_user.github_account,
      blog_url: current_user.blog_url,
      graduated: current_user.graduated?
    )
  end

  def today_to_tomorrow
    (Time.zone.today + 9.hours)..(Time.zone.tomorrow + 9.hours)
  end

  def tomorrow_to_day_after_tomorrow
    (Time.zone.tomorrow + 9.hours)..(Time.zone.tomorrow + 1.day + 9.hours)
  end

  def display_dashboard
    @announcements = Announcement.with_avatar.where(wip: false).order(published_at: :desc).limit(5)
    @bookmarks = current_user.bookmarks.order(created_at: :desc).limit(5)
    @completed_learnings = current_user.learnings.where(status: 3).includes(:practice).order(updated_at: :desc)
    @inactive_students = User.with_attached_avatar.inactive_students_and_trainees.order(last_activity_at: :desc)
    @job_seeking_users = User.with_attached_avatar.job_seeking.includes(:reports, :products, :works, :course, :company)
    @collegue_trainees = current_user.collegue_trainees&.with_attached_avatar&.includes(:reports, :products, :comments)
    collegue_trainees_reports = Report.with_avatar.where(wip: false).where(user: current_user.collegue_trainees&.with_attached_avatar)
    @collegue_trainees_recent_reports = collegue_trainees_reports.order(reported_on: :desc).limit(10)
  end

  def display_events_on_dashboard
    cookies_ids = JSON.parse(cookies[:confirmed_event_ids]) if cookies[:confirmed_event_ids]
    @events_coming_soon = Event.where(start_at: today_to_tomorrow).or(Event.where(start_at: tomorrow_to_day_after_tomorrow)).where.not(id: cookies_ids)
    @events_coming_soon_except_job_hunting = @events_coming_soon.where.not(job_hunting: true)
  end

  def display_regular_events_on_dashboard
    cookies_ids = JSON.parse(cookies[:confirmed_regular_event_ids]) if cookies[:confirmed_regular_event_ids]
    @regular_events_holding_today_for_current_user, @regular_events_holding_tomorrow_for_current_user =
      [RegularEvent.today_events, RegularEvent.tomorrow_events].map do |regular_events|
        regular_events.select { |event| event.participated_by?(current_user) }
      end

    cookies_ids&.each do |id|
      [@regular_events_holding_today_for_current_user, @regular_events_holding_tomorrow_for_current_user].each do |regular_events|
        regular_events.delete_if do |event|
          event.id == id.to_i
        end
      end
    end
  end

  def display_welcome_message_for_adviser
    @welcome_message_first_time = cookies[:confirmed_welcome_message]
  end
end
