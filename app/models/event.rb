# frozen_string_literal: true

class Event < ApplicationRecord
  include WithAvatar
  include Commentable
  include Footprintable
  include Reactionable
  include Watchable
  include Searchable

  validates :title, presence: true
  validates :description, presence: true
  validates :location, presence: true
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :open_start_at, presence: true
  validates :open_end_at, presence: true

  after_create EventCallbacks.new

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

  columns_for_keyword_search :title, :description

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
    first_come_first_served.limit(capacity)
  end

  def waitlist
    first_come_first_served - participants
  end

  def participants_count
    users.size > capacity ? capacity : users.size
  end

  def waitlist_count
    users.size > capacity ? users.size - capacity : 0
  end

  def can_participate?
    first_come_first_served.count < capacity
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
    NotificationFacade.moved_up_event_waiting_user(self, receiver)
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
