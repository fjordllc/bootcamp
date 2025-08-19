# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :require_active_user_login, raise: false

  def index
    if current_user
      display_dashboard
      display_events_on_dashboard
      display_welcome_message_for_adviser
      set_required_fields
      display_products_for_mentor
      render action: :index
    else
      @mentors = User.with_attached_profile_image.mentor.includes(authored_books: { cover_attachment: :blob })
      @articles = list_articles_with_specific_tag
      render template: 'welcome/index', layout: 'lp'
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
      discord_account_name: current_user.discord_profile.account_name,
      github_account: current_user.github_account,
      blog_url: current_user.blog_url,
      graduated: current_user.graduated?,
      learning_time_frames: current_user.graduated? || current_user.learning_time_frames.exists?
    )
  end

  def display_dashboard
    @announcements = Announcement.with_avatar.where(wip: false).order(published_at: :desc).limit(5)
    @bookmarks = current_user.bookmarks.order(created_at: :desc).limit(5)
    @completed_learnings = current_user.learnings.where(status: 3).includes(:practice).order(updated_at: :desc)
    @inactive_students = User.with_attached_avatar.inactive_students_and_trainees.order(last_activity_at: :desc)
    @job_seeking_users = User.with_attached_avatar.job_seeking.includes(:reports, :products, :works, :course, :company)
    @colleague_trainees = current_user.colleague_trainees.with_attached_avatar.includes(:reports, :products, :comments)
    colleague_trainees_reports = Report.with_avatar.where(wip: false).where(user: current_user.colleague_trainees.with_attached_avatar)
    @colleague_trainees_recent_reports = colleague_trainees_reports.order(reported_on: :desc).limit(10)
    @recent_reports = Report.with_avatar.where(wip: false).order(reported_on: :desc, created_at: :desc).limit(10)
    @product_deadline_day = Product::PRODUCT_DEADLINE
    @colleagues = current_user.colleagues_other_than_self
    @calendar = NicoNicoCalendar.new(current_user, params[:niconico_calendar])
    @target_end_date = GrassDateParameter.new(params[:end_date]).target_end_date
    @times = Grass.times(current_user, @target_end_date)
  end

  def display_events_on_dashboard
    @upcoming_events_groups = UpcomingEvent.upcoming_events_groups
  end

  def display_welcome_message_for_adviser
    @welcome_message_first_time = cookies[:confirmed_welcome_message]
  end

  def display_products_for_mentor
    @products = Product.require_assignment_products
    @products_grouped_by_elapsed_days = Product.group_by_elapsed_days(@products)
  end

  def list_articles_with_specific_tag
    Article.tagged_with('注目の記事').order(published_at: :desc).where(wip: false).first(6)
  end
end
