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

  belongs_to :user
  has_many :participations, dependent: :destroy
  has_many :users, through: :participations

  def is_opening?
    Time.current.between?(open_start_at, open_end_at)
  end

  def before_opening?
    Time.current < open_start_at
  end

  def is_closing?
    Time.current > open_end_at && Time.current < end_at
  end

  def participants
    first_come_first_served.limit(capacity)
  end

  def waitlist
    first_come_first_served - participants
  end

  private
    def end_at_be_greater_than_start_at
      diff = end_at - start_at
      if diff <= 0
        errors.add(:end_at, ": 終了日時は開始日時よりも後の日時にしてください。")
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
        errors.add(:open_start_at, ": 募集開始日時は開始日時よりも前の日時にしてください。")
      end
    end

    def open_end_at_be_less_than_end_at
      diff = end_at - open_end_at
      if diff < 0
        errors.add(:open_end_at, ": 募集終了日時は終了日時よりも前の日時にしてください。")
      end
    end

    def first_come_first_served
      users.order("participations.created_at asc")
    end
end
