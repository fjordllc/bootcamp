# frozen_string_literal: true

class RegularEvent < ApplicationRecord # rubocop:disable Metrics/ClassLength
  attr_accessor :start_on, :end_on

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
  include Searchable

  enum category: {
    reading_circle: 0,
    chat: 1,
    question: 2,
    meeting: 3,
    others: 4
  }, _prefix: true

  validates :title, presence: true, markdown_prohibited: true
  validates :user_ids, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :finished, inclusion: { in: [true, false] }
  validates :hold_national_holiday, inclusion: { in: [true, false] }
  validates :description, presence: true
  validates :regular_event_repeat_rules, presence: true
  validates_associated :regular_event_repeat_rules

  scope :not_finished, -> { where(finished: false) }

  with_options if: -> { start_at && end_at } do
    validate :end_at_be_greater_than_start_at
  end

  scope :holding, -> { where(finished: false) }
  scope :participated_by, ->(user) { where(id: all.filter { |e| e.participated_by?(user) }.map(&:id)) }
  scope :organizer_event, ->(user) { where(id: user.organizers.map(&:regular_event_id)) }
  scope :scheduled_on, ->(date) { holding.filter { |event| event.scheduled_on?(date) } }
  scope :not_ended, -> { where('end_at > ?', Time.current) }
  scope :scheduled_on_without_ended, ->(date) { holding.not_ended.filter { |event| event.scheduled_on?(date) } }

  belongs_to :user
  has_many :organizers, dependent: :destroy
  has_many :users, through: :organizers
  has_many :regular_event_repeat_rules, dependent: :destroy
  accepts_nested_attributes_for :regular_event_repeat_rules, allow_destroy: true
  has_many :regular_event_participations, dependent: :destroy
  has_many :participants,
           through: :regular_event_participations,
           source: :user
  has_many :watches, as: :watchable, dependent: :destroy
  has_many :footprints, as: :footprintable, dependent: :destroy
  attribute :wants_announcement, :boolean

  columns_for_keyword_search :title, :description

  def scheduled_on?(date)
    all_scheduled_dates.include?(date)
  end

  def next_event_date
    event_dates =
      hold_national_holiday ? upcoming_scheduled_dates : upcoming_scheduled_dates.reject { |d| HolidayJp.holiday?(d) }

    event_dates.min
  end

  def organizers
    users.with_attached_avatar.order('organizers.created_at')
  end

  def cancel_participation(user)
    regular_event_participation = regular_event_participations.find_by(user_id: user.id)
    regular_event_participation.destroy
  end

  def watched_by?(user)
    watches.exists?(user_id: user.id)
  end

  def participated_by?(user)
    regular_event_participations.find_by(user_id: user.id).present?
  end

  def assign_admin_as_organizer_if_none
    return if organizers.exists?

    admin_user = User.find_by(login_name: User::DEFAULT_REGULAR_EVENT_ORGANIZER)
    Organizer.new(user: admin_user, regular_event: self).save if admin_user
  end

  def all_scheduled_dates(
    from: Date.current,
    to: Date.current.next_year
  )
    (from..to).filter { |d| date_match_the_rules?(d, regular_event_repeat_rules) }
  end

  def transform_for_subscription(event_date)
    regular_event = dup

    regular_event.assign_attributes(
      start_on: parse_event_time(event_date, regular_event.start_at),
      end_on: parse_event_time(event_date, regular_event.end_at)
    )

    regular_event
  end

  def self.fetch_participated_regular_events(user)
    participated_regular_events = []
    user.participated_regular_event_ids.find_each do |regular_event|
      regular_event.all_scheduled_dates.each do |event_date|
        participated_regular_events << regular_event.transform_for_subscription(event_date)
      end
    end
    participated_regular_events
  end

  def publish_with_announcement?
    wants_announcement? && !wip?
  end

  private

  def end_at_be_greater_than_start_at
    diff = end_at - start_at
    return unless diff <= 0

    errors.add(:end_at, ': イベント終了時刻はイベント開始時刻よりも後の時刻にしてください。')
  end

  def upcoming_scheduled_dates
    # 時刻が過ぎたイベントを排除するためだけに、一時的にstart_timeを与える。後でDate型に戻す。
    event_dates_with_start_time = all_scheduled_dates.map { |d| d.in_time_zone.change(hour: start_at.hour, min: start_at.min) }

    event_dates_with_start_time.reject { |d| d < Time.zone.now }.map(&:to_date)
  end

  def date_match_the_rules?(date, rules)
    rules.any? do |rule|
      if rule.frequency.zero?
        rule.day_of_the_week == date.wday
      else
        rule.frequency == nth_wday(date) && rule.day_of_the_week == date.wday
      end
    end
  end

  def nth_wday(date)
    (date.day + 6) / 7
  end

  def parse_event_time(event_date, event_time)
    str_date = event_date.strftime('%F')
    str_time = event_time.strftime('%R')
    Time.zone.parse([str_date, str_time].join(' '))
  end
end
