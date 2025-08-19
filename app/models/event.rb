# frozen_string_literal: true

class Event < ApplicationRecord # rubocop:todo Metrics/ClassLength
  include WithAvatar
  include Commentable
  include Footprintable
  include Reactionable
  include Watchable
  include Searchable
  include SearchHelper

  validates :title, presence: true
  validates :description, presence: true
  validates :location, presence: true
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :open_start_at, presence: true
  validates :open_end_at, presence: true

  with_options if: -> { start_at && end_at } do
    validate :end_at_be_greater_than_start_at
  end

  with_options if: -> { open_start_at && open_end_at } do
    validate :open_end_at_be_greater_than_open_start_at
  end

  with_options if: -> { open_start_at && start_at } do
    validate :open_start_at_be_less_than_start_at
  end

  with_options if: -> { open_end_at && end_at } do
    validate :open_end_at_be_less_than_end_at
  end

  belongs_to :user
  has_many :participations, dependent: :destroy
  has_many :users, through: :participations
  has_many :watches, as: :watchable, dependent: :destroy
  has_many :footprints, as: :footprintable, dependent: :destroy
  attribute :announcement_of_publication, :boolean

  columns_for_keyword_search :title, :description

  scope :wip, -> { where(wip: true) }
  scope :related_to, ->(user) { user.job_seeker ? all : where.not(job_hunting: true) }
  scope :scheduled_on, ->(date) { where(start_at: date.midnight...(date + 1.day).midnight) }
  scope :not_ended, -> { where('end_at > ?', Time.current) }
  scope :scheduled_on_without_ended, ->(date) { scheduled_on(date).not_ended }

  def opening?
    Time.current.between?(open_start_at, open_end_at)
  end

  def before_opening?
    Time.current < open_start_at
  end

  def closing?
    Time.current > open_end_at && Time.current < end_at
  end

  def ended?
    Time.current >= end_at
  end

  def participants
    users.where('participations.enable = true').order(created_at: :asc)
  end

  def waitlist
    users.where('participations.enable = false').order(created_at: :asc)
  end

  def can_participate?
    participants.count < capacity
  end

  def cancel_participation!(user)
    participation = participations.find_by(user_id: user.id)
    participation.destroy

    return unless participation.enable

    move_up_participation = waiting_particpations.first

    return unless move_up_participation

    move_up_participation.update!(enable: true)
    send_notification(move_up_participation.user)
  end

  def update_participations
    first_come_participations.each.with_index(1) do |participation, i|
      if i <= capacity
        participation.update(enable: true)
        send_notification(participation.user) if participation.waited?
      else
        participation.update(enable: false)
      end
    end
  end

  def send_notification(receiver)
    ActivityDelivery.with(receiver:, event: self).notify(:moved_up_event_waiting_user)
  end

  def watched_by?(user)
    watches.exists?(user_id: user.id)
  end

  def can_move_up_the_waitlist?
    waitlist.count.positive? && can_participate?
  end

  def self.fetch_participated_ids(user)
    user.participations.pluck(:event_id)
  end

  def self.fetch_upcoming_ids
    Event.where('start_at > ?', Date.current).pluck(:id)
  end

  private

  def end_at_be_greater_than_start_at
    diff = end_at - start_at
    return unless diff <= 0

    errors.add(:end_at, ': イベント終了日時はイベント開始日時よりも後の日時にしてください。')
  end

  def open_end_at_be_greater_than_open_start_at
    diff = open_end_at - open_start_at
    return unless diff <= 0

    errors.add(:open_end_at, ': 募集終了日時は募集開始日時よりも後の日時にしてください。')
  end

  def open_start_at_be_less_than_start_at
    diff = start_at - open_start_at
    return unless diff <= 0

    errors.add(:open_start_at, ': 募集開始日時はイベント開始日時よりも前の日時にしてください。')
  end

  def open_end_at_be_less_than_end_at
    diff = end_at - open_end_at
    return unless diff.negative?

    errors.add(:open_end_at, ': 募集終了日時はイベント終了日時よりも前の日時にしてください。')
  end

  def first_come_first_served
    users.order('participations.created_at asc')
  end

  def first_come_participations
    participations.order(created_at: :asc)
  end

  def waiting_particpations
    participations.disabled
                  .order(created_at: :asc)
  end
end
