# frozen_string_literal: true

class Event < ApplicationRecord
  include WithAvatar
  include Commentable
  include Footprintable
  include Reactionable

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

  after_update EventCallbacks.new

  belongs_to :user
  has_many :participations, dependent: :destroy
  has_many :users, through: :participations

  def opening?
    Time.current.between?(open_start_at, open_end_at)
  end

  def before_opening?
    Time.current < open_start_at
  end

  def closing?
    Time.current > open_end_at && Time.current < end_at
  end

  def participants
    first_come_first_served.limit(capacity)
  end

  def waitlist
    first_come_first_served - participants
  end

  def can_participate?
    first_come_first_served.count <= capacity
  end

  def cancel_participation!(user:)
    participation = self.participations.find_by(user_id: user.id)
    participation.destroy

    return unless participation.enable

    event = self
    first_waiting_participation = first_waiting_participation(event)

    if first_waiting_participation
      first_waiting_participation.update!(enable: true)
      send_notification(event, first_waiting_participation.user)
    end
  end

  private
    def end_at_be_greater_than_start_at
      diff = end_at - start_at
      if diff <= 0
        errors.add(:end_at, ": イベント終了日時はイベント開始日時よりも後の日時にしてください。")
      end
    end

    def open_end_at_be_greater_than_open_start_at
      diff = open_end_at - open_start_at
      if diff <= 0
        errors.add(:open_end_at, ": 募集終了日時は募集開始日時よりも後の日時にしてください。")
      end
    end

    def open_start_at_be_less_than_start_at
      diff = start_at - open_start_at
      if diff <= 0
        errors.add(:open_start_at, ": 募集開始日時はイベント開始日時よりも前の日時にしてください。")
      end
    end

    def open_end_at_be_less_than_end_at
      diff = end_at - open_end_at
      if diff < 0
        errors.add(:open_end_at, ": 募集終了日時はイベント終了日時よりも前の日時にしてください。")
      end
    end

    def first_come_first_served
      users.order("participations.created_at asc")
    end

    def first_waiting_participation(event)
      event.participations
           .disabled
           .order(created_at: :asc)
           .first
    end

    def send_notification(event, receiver)
      NotificationFacade.moved_up_event_waiting_user(event, receiver)
    end
end
