# frozen_string_literal: true

class Campaign < ApplicationRecord
  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :title, presence: true

  # TODO: Rails 7に更新後、 `ComparisonValidator` を使うように直す。
  # refs: https://github.com/rails/rails/pull/40095
  # validates :end_at, greater_than: :start_at
  with_options if: -> { start_at && end_at } do
    validate :end_at_be_greater_than_start_at
  end

  def self.recently_campaign
    campaign = Campaign.order(end_at: :desc).first
    return if campaign.nil?

    campaign.start_at..campaign.end_at
  end

  def self.today_is_campaign?
    return if recently_campaign.nil?

    recently_campaign.cover?(Time.current)
  end

  def self.current_title
    return if !today_is_campaign?

    Campaign.order(end_at: :desc).first.title
  end

  private

  def end_at_be_greater_than_start_at
    diff = end_at - start_at
    return unless diff <= 0

    errors.add(:end_at, ': 終了日時は開始日時よりも後の日時にしてください。')
  end
end
