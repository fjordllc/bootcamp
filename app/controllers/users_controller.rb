# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: %i[show]
  before_action :set_user, only: %w[show]

  PAGER_NUMBER = 24

  def index
    @target = params[:target]
    @target = 'student_and_trainee' unless target_allowlist.include?(@target)
    @entered_tag = params[:tag]
    @watch = params[:watch]

    target_users = fetch_target_users

    if params[:search_word]
      search_user = SearchUser.new(word: params[:search_word], users: target_users, target: @target)
      @users = search_user.search
                          .page(params[:page]).per(PAGER_NUMBER)
                          .preload(:avatar_attachment, :course, :taggings)
                          .order(updated_at: :desc)
    else
      @users = target_users
               .page(params[:page]).per(PAGER_NUMBER)
               .preload(:avatar_attachment, :course, :taggings)
               .order(updated_at: :desc)
    end

    @random_tags = User.tags.sample(20)
    @top3_tags_counts = User.tags.limit(3).map(&:count).uniq
    @tag = ActsAsTaggableOn::Tag.find_by(name: params[:tag])
  end

  def show
    @completed_learnings = @user
                           .learnings
                           .includes(:practice)
                           .where(status: 3)
                           .order(updated_at: :desc)

    @calendar = NicoNicoCalendar.new(@user, params[:niconico_calendar])

    @target_end_date = GrassDateParameter.new(params[:end_date]).target_end_date
    @times = Grass.times(@user, @target_end_date)

    reports = @user.reports_with_learning_times
    @study_streak = StudyStreak.new(reports, include_wip: false)

    if logged_in?
      render :show
    else
      render :unauthorized_show, layout: 'not_logged_in'
    end
  end

  def toggle_show_study_streak
    enabled = params[:toggle].present?
    current_user.update!(show_study_streak: enabled)

    redirect_to url_from(params[:redirect_to]) || root_path
  end

  private

  def fetch_target_users
    if @target == 'followings'
      current_user.followees_list(watch: @watch)
    elsif @entered_tag
      User.active_tagged_with(@entered_tag)
    else
      users = User.users_role(@target, allowed_targets: target_allowlist)
      @target == 'inactive' ? users.order(:last_activity_at) : users
    end
  end

  def target_allowlist
    target_allowlist = %w[student_and_trainee student trainee followings mentor graduate adviser year_end_party]
    target_allowlist.push('job_seeking') if current_user.adviser?
    target_allowlist.concat(%w[job_seeking hibernated retired inactive all]) if current_user.mentor? || current_user.admin?
    target_allowlist
  end

  def set_user
    @user = User.where(id: params[:id]).or(User.where(login_name: params[:id])).first!
  end

  def require_token
    return unless params[:role]
    return unless !params[:token] || !ENV['TOKEN'] || params[:token] != ENV['TOKEN']

    redirect_to root_path, notice: 'アドバイザー・メンター・研修生登録にはTOKENが必要です。'
  end
end
