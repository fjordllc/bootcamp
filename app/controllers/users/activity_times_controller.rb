# frozen_string_literal: true

class Users::ActivityTimesController < ApplicationController
  PAGER_NUMBER = 24

  def index
    set_current_time
    @target_day_of_week = params[:day_of_week] || @current_day_of_week
    @target_hour = params[:hour] || @current_hour

    Rails.logger.debug "ActivityTimes: day_of_week=#{@target_day_of_week}, hour=#{@target_hour}"

    target_users = fetch_users_by_activity_time(@target_day_of_week, @target_hour)
    Rails.logger.debug "ActivityTimes: target_users.count=#{target_users.count}"

    @users = target_users
             .page(params[:page]).per(PAGER_NUMBER)
             .preload(:avatar_attachment, :course, :taggings)
             .order(updated_at: :desc)

    Rails.logger.debug "ActivityTimes: @users.count=#{@users.count}"
    Rails.logger.debug "ActivityTimes: @users.total_count=#{@users.total_count}"
  end

  private

  def set_current_time
    now = Time.current
    @current_day_of_week = now.wday.to_s
    @current_hour = now.hour.to_s
  end

  def fetch_users_by_activity_time(day_of_week, hour)
    return User.none unless valid_day_of_week?(day_of_week) && valid_hour?(hour)

    # 曜日名を数値から文字列に変換
    week_day_name = convert_day_of_week_to_name(day_of_week)

    # 指定された曜日と時間に活動時間を設定しているユーザーを取得
    User.joins(:learning_time_frames)
        .where(learning_time_frames: { week_day: week_day_name, activity_time: hour.to_i })
        .students_and_trainees
        .distinct
  end

  def convert_day_of_week_to_name(day_of_week)
    day_names = %w[日 月 火 水 木 金 土]
    day_names[day_of_week.to_i]
  end

  def valid_day_of_week?(day_of_week)
    day_of_week.to_s.match?(/\A[0-6]\z/)
  end

  def valid_hour?(hour)
    hour.to_s.match?(/\A(?:[0-9]|1[0-9]|2[0-3])\z/)
  end
end
