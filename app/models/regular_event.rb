# frozen_string_literal: true

class RegularEvent < ApplicationRecord # rubocop:disable Metrics/ClassLength
  DAYS_OF_THE_WEEK_COUNT = 7

  FREQUENCY_LIST = [
    ['毎週', 0],
    ['第1', 1],
    ['第2', 2],
    ['第3', 3],
    ['第4', 4]
  ].freeze

  DAY_OF_THE_WEEK_LIST = [
    ['日曜日', 0],
    ['月曜日', 1],
    ['火曜日', 2],
    ['水曜日', 3],
    ['木曜日', 4],
    ['金曜日', 5],
    ['土曜日', 6]
  ].freeze

  include WithAvatar
  include Commentable
  include Footprintable
  include Reactionable
  include Watchable

  enum category: {
    reading_circle: 0,
    chat: 1,
    question: 2,
    meeting: 3,
    others: 4
  }, _prefix: true

  validates :title, presence: true
  validates :user_ids, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :finished, inclusion: { in: [true, false] }
  validates :hold_national_holiday, inclusion: { in: [true, false] }
  validates :description, presence: true
  validates :regular_event_repeat_rules, presence: true
  validates_associated :regular_event_repeat_rules

  with_options if: -> { start_at && end_at } do
    validate :end_at_be_greater_than_start_at
  end

  scope :holding, -> { where(finished: false) }

  belongs_to :user
  has_many :organizers, dependent: :destroy
  has_many :users, through: :organizers
  has_many :regular_event_repeat_rules, dependent: :destroy
  accepts_nested_attributes_for :regular_event_repeat_rules, allow_destroy: true
  has_many :watches, as: :watchable, dependent: :destroy

  def organizers
    users.with_attached_avatar.order('organizers.created_at')
  end

  def event_day?
    now = Time.current
    event_day = regular_event_repeat_rules.map do |repeat_rule|
      if repeat_rule.frequency.zero?
        repeat_rule.day_of_the_week == now.wday
      else
        repeat_rule.day_of_the_week == now.wday && repeat_rule.frequency == convert_date_into_week(now.day)
      end
    end.include?(true)
    event_start_time = Time.zone.local(now.year, now.month, now.day, start_at.hour, start_at.min, 0)

    event_day && (now < event_start_time)
  end

  def convert_date_into_week(date)
    (date / 7.0).ceil
  end

  def next_event_date
    today = Time.zone.today
    this_month_first_day = Date.new(today.year, today.mon, 1)
    next_month_first_day = this_month_first_day.next_month

    possible_dates = regular_event_repeat_rules.map do |repeat_rule|
      [
        possible_next_event_date(this_month_first_day, repeat_rule),
        possible_next_event_date(next_month_first_day, repeat_rule)
      ]
    end.flatten
    possible_dates.compact.select { |possible_date| possible_date > Time.zone.today }.min
  end

  def possible_next_event_date(first_day, repeat_rule)
    if repeat_rule.frequency.zero?
      next_specific_day_of_the_week(repeat_rule) if Time.zone.today.mon == first_day.mon
    else
      # 次の第n X曜日の日付を計算する
      date = (repeat_rule.frequency - 1) * DAYS_OF_THE_WEEK_COUNT + repeat_rule.day_of_the_week - first_day.wday + 1
      date += DAYS_OF_THE_WEEK_COUNT if repeat_rule.day_of_the_week < first_day.wday
      Date.new(first_day.year, first_day.mon, date)
    end
  end

  def next_specific_day_of_the_week(repeat_rule)
    day_of_the_week_symbol = DateAndTime::Calculations::DAYS_INTO_WEEK.key(repeat_rule.day_of_the_week)
    0.days.ago.next_occurring(day_of_the_week_symbol).to_date
  end

  def tomorrow_event?
    tomorrow = Time.current.next_day
    regular_event_repeat_rules.map do |repeat_rule|
      if repeat_rule.frequency.zero?
        repeat_rule.day_of_the_week == tomorrow.wday
      else
        repeat_rule.day_of_the_week == tomorrow.wday && repeat_rule.frequency == convert_date_into_week(tomorrow.day)
      end
    end.include?(true)
  end

  class << self
    def tomorrow_events
      holding_events = RegularEvent.holding
      holding_events.select(&:tomorrow_event?)
    end
  end

  private

  def end_at_be_greater_than_start_at
    diff = end_at - start_at
    return unless diff <= 0

    errors.add(:end_at, ': イベント終了時刻はイベント開始時刻よりも後の時刻にしてください。')
  end
end
