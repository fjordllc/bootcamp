# frozen_string_literal: true

class Campaign < ApplicationRecord
  validates :start_at, presence: true
  validates :end_at, presence: true

  # TODO: Rails 7に更新後、 `ComparisonValidator` を使うように直す。
  # refs: https://github.com/rails/rails/pull/40095
  # validates :end_at, greater_than: :start_at
  with_options if: -> { start_at && end_at && trial_period } do
    validate :start_at_cannot_be_greater_than_end_at
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

    def current_trial_period
      today_campaign? ? Campaign.order(end_at: :desc).first.trial_period : 3
    end

    def example_start_at
      Time.current.strftime('%-m月%-d日10時10分10秒')
    end

    def example_end_at
      (Time.current + current_trial_period.days - 1).strftime('%-m月%-d日10時10分9秒')
    end

    def example_pay_at
      (Time.current + current_trial_period.days).strftime('%-m月%-d日10時10分10秒')
    end

    def user_trial_period(join_date)
      Campaign.find_each do |camp|
        return camp.trial_period if (camp.start_at..camp.end_at).cover?(join_date)
      end
    end
  end

  private

  def start_at_cannot_be_greater_than_end_at
    return if end_at > start_at

    errors.add(:end_at, :format, shortest_end_at: I18n.l(start_at, format: :short))
  end
end
