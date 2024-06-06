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
  include Searchable

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

  scope :not_finished, -> { where(finished: false) }

  with_options if: -> { start_at && end_at } do
    validate :end_at_be_greater_than_start_at
  end

  scope :holding, -> { where(finished: false) }
  scope :participated_by, ->(user) { where(id: all.filter { |e| e.participated_by?(user) }.map(&:id)) }
  scope :organizer_event, ->(user) { where(id: user.organizers.map(&:regular_event_id)) }
  scope :scheduled_on, ->(date) { holding.filter { |event| event.scheduled_on?(date) } }

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
  attribute :wants_announcement, :boolean

  columns_for_keyword_search :title, :description

  def scheduled_on?(date)
    all_scheduled_dates.include?(date)
  end

  def next_event_date
    event_dates =
      hold_national_holiday ? feature_scheduled_dates : feature_scheduled_dates.reject { |d| HolidayJp.holiday?(d) }

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

  def fetch_participated_regular_events(user)
    participated_events = user.regular_event_participations.pluck(:regular_event_id)
    participated_regular_events = []
    RegularEvent.where(id: participated_events).where(finished: false).find_each do |event|
      event.regular_event_repeat_rules.each do |repeat_rule|
        current_date = Time.zone.today

        list_regular_event_for_year(event, repeat_rule, current_date, participated_regular_events)
      end
    end
    participated_regular_events
  end

  def format_participated_regular_events(participated_regular_events)
    participated_regular_events.map do |participated_event|
      event = participated_event[:event].dup
      event_date = participated_event[:event_date]
      tzid = 'Asia/Tokyo'

      event.assign_attributes(
        start_at: Icalendar::Values::DateTime.new(
          DateTime.parse("#{event_date} #{event.start_at.strftime('%H:%M')}"), 'tzid' => tzid
        ),
        end_at: Icalendar::Values::DateTime.new(
          DateTime.parse("#{event_date} #{event.end_at.strftime('%H:%M')}"), 'tzid' => tzid
        )
      )
      event
    end
  end

  private

  def end_at_be_greater_than_start_at
    diff = end_at - start_at
    return unless diff <= 0

    errors.add(:end_at, ': イベント終了時刻はイベント開始時刻よりも後の時刻にしてください。')
  end

  def all_scheduled_dates(
    from: Date.new(Time.current.year, 1, 1),
    to: Date.new(Time.current.year, 12, 31)
  )
    (from..to).filter { |d| date_match_the_rules?(d, regular_event_repeat_rules) }
  end

  def feature_scheduled_dates
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
  
  def list_regular_event_for_year(event,  repeat_rule, current_date, participated_regular_events)
    while current_date <= Time.zone.today + 1.year
      if repeat_rule.frequency.zero?
        day_of_the_week_symbol = DateAndTime::Calculations::DAYS_INTO_WEEK.key(repeat_rule.day_of_the_week)
        event_date = current_date.next_occurring(day_of_the_week_symbol).to_date
        event_date = event_date.next_occurring(day_of_the_week_symbol) while !event.hold_national_holiday && HolidayJp.holiday?(event_date)
        current_date = event_date + 1
      else
        event_date = event.possible_next_event_date(current_date, repeat_rule)
        current_date = current_date.next_month.beginning_of_month
      end
      participated_regular_events << { event:, event_date: }
    end
  end
end
