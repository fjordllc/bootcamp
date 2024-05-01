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
  scope :today_events, -> { where(id: holding.select(&:holding_today?).map(&:id)) }
  scope :tomorrow_events, -> { where(id: holding.select(&:holding_tomorrow?).map(&:id)) }
  scope :day_after_tomorrow_events, -> { where(id: holding.select(&:holding_day_after_tomorrow?).map(&:id)) }
  scope :participated_by, ->(user) { where(id: all.select { |e| e.participated_by?(user) }.map(&:id)) }
  scope :organizer_event, ->(user) { where(id: user.organizers.map(&:regular_event_id)) }

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

  def organizers
    users.with_attached_avatar.order('organizers.created_at')
  end

  def holding_today?
    holding_on?(0)
  end

  def holding_tomorrow?
    holding_on?(1)
  end

  def holding_day_after_tomorrow?
    holding_on?(2)
  end

  def next_event_date
    schedule = EventSchedule.load(self)
    start = Time.current
    last = start.next_year.end_of_month

    schedule.held_next_event_date(from: start, to: last).to_date
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

  private

  def end_at_be_greater_than_start_at
    diff = end_at - start_at
    return unless diff <= 0

    errors.add(:end_at, ': イベント終了時刻はイベント開始時刻よりも後の時刻にしてください。')
  end

  def holding_on?(days_from_today)
    schedule = EventSchedule.load(self)
    start = Time.current
    last = start.next_year.end_of_month
    dates = schedule.gather_scheduled_dates(from: start, to: last)

    dates.select do |d|
      d.to_date == Time.zone.today + days_from_today.days
    end.min
  end
end
