# frozen_string_literal: true

class Campaign < ApplicationRecord
  validates :start_at, presence: true
  validates :end_at, presence: true

  # TODO: Rails 7に更新後、 `ComparisonValidator` を使うように直す。
  # refs: https://github.com/rails/rails/pull/40095
  # validates :end_at, greater_than: :start_at
  with_options if: -> { start_at && end_at && trial_period } do
    validate :end_at_be_greater_than_trial_period
  end

  validates :title, presence: true
  validates :trial_period, presence: true, numericality: { greater_than_or_equal_to: 4 }

  class << self
    def recently_campaign
      campaign = Campaign.order(end_at: :desc).first
      return if campaign.nil?

      campaign.start_at..campaign.end_at
    end

    def today_campaign?
      return if recently_campaign.nil?

      recently_campaign.cover?(Time.current)
    end

    def current_title
      return unless today_campaign?

      Campaign.order(end_at: :desc).first.title
    end
  end

  def self.trial_period
    campaign = Campaign.order(end_at: :desc).first
    return if Campaign.nil?

    today_campaign? ? campaign.trial_period : 3
  end

  private

  def end_at_be_greater_than_trial_period
    diff = end_at - start_at
    period = trial_period.days - 1.minute
    return if diff >= period

    shortest_end_at = start_at + period
    errors.add(:end_at, "は#{I18n.l(shortest_end_at, format: :short)}以降を入力してください。")
  end
end
