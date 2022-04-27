# frozen_string_literal: true

class RegularEvent < ApplicationRecord
  include WithAvatar
  include Commentable
  include Footprintable
  include Reactionable
  include Watchable
  include Searchable

  validates :title, presence: true
  validates :description, presence: true
  validates :finished, inclusion: { in: [true, false] }
  validates :hold_national_holiday, inclusion: { in: [true, false] }
  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :wday, presence: true

  after_create EventCallbacks.new

  with_options if: -> { start_at && end_at } do
    validate :end_at_be_greater_than_start_at
  end

  belongs_to :user
  has_many :watches, as: :watchable, dependent: :destroy

  columns_for_keyword_search :title, :description

  private

  def end_at_be_greater_than_start_at
    diff = end_at - start_at
    return unless diff <= 0

    errors.add(:end_at, ': 定期イベント終了時刻はイベント開始時刻よりも後の時刻にしてください。')
  end
end
