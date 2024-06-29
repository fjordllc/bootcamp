# frozen_string_literal: true

class Calendar::NicoNicoCalendarComponent < ViewComponent::Base
  def initialize(user:, path:, current_date:, current_calendar:)
    @user = user
    @path = path
    @current_date = current_date
    @current_calendar = current_calendar
  end

  def prev_month?(month)
    month.beginning_of_month > user.created_at.to_date.beginning_of_month
  end

  def frame_and_background(date, emotion)
    day_class = emotion ? "is-#{emotion}" : 'is-blank'
    day_class += ' is-today' if date&.today?
    day_class
  end

  def next_month?(month)
    month.beginning_of_month < Time.zone.today.to_date.beginning_of_month
  end

  private

  attr_reader :user, :path, :current_date, :current_calendar
end
