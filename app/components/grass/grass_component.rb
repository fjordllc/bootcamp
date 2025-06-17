# frozen_string_literal: true

class Grass::GrassComponent < ViewComponent::Base
  def initialize(user:, times:, target_end_date:, path:)
    @user = user
    @times = times
    @target_end_date = target_end_date
    @path = path
  end

  def next_year?
    @target_end_date.next_year < Date.current
  end

  def prev_year_path
    send(@path, end_date: @target_end_date.prev_year.to_s)
  end

  def next_year_path
    send(@path, end_date: @target_end_date.next_year.to_s)
  end

  private

  attr_reader :user, :times, :target_end_date, :path

end
