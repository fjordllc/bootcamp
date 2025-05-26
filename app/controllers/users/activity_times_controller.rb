# frozen_string_literal: true

class Users::ActivityTimesController < ApplicationController
  PAGER_NUMBER = 24

  def index
    set_current_time
    @target_day_of_week = params[:day_of_week] || @current_day_of_week
    @target_hour = params[:hour] || @current_hour

    target_users = fetch_users_by_activity_time(@target_day_of_week, @target_hour)

    @users = target_users
             .page(params[:page]).per(PAGER_NUMBER)
             .preload(:avatar_attachment, :course, :taggings)
             .order(updated_at: :desc)
  end

  private

  def set_current_time
    now = Time.current
    @current_day_of_week = now.wday.to_s
    @current_hour = now.hour.to_s
  end

  def fetch_users_by_activity_time(day_of_week, hour)
    return User.none unless day_of_week.to_s.match?(/\A[0-6]\z/) && hour.to_s.match?(/\A(?:[0-9]|1[0-9]|2[0-3])\z/)

    week_day_name = helpers.day_of_the_week[day_of_week.to_i]

    User.joins(learning_time_frames_users: :learning_time_frame)
        .where(learning_time_frames: { week_day: week_day_name, activity_time: hour.to_i })
        .students_trainees_mentors_and_admins
        .distinct
  end
end
