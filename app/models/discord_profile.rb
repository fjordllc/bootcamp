# frozen_string_literal: true

class DiscordProfile < ApplicationRecord
  belongs_to :user

  validates :times_url,
            format: {
              allow_blank: true,
              with: %r{\Ahttps://discord\.com/channels/\d+/\d+\z},
              message: 'は https://discord.com/channels/ で始まる Discord のチャンネル URL を入力してください。'
            }
  with_options if: -> { validation_context != :retirement } do
    validates :account_name,
              allow_blank: true,
              length: {
                in: 2..32,
                message: 'は2文字以上32文字以内で入力してください。'
              }
    validate :validate_only_underscore_and_period
    validate :no_consecutive_periods
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[account_name created_at id times_id times_url updated_at user_id]
  end

  private

  def validate_only_underscore_and_period
    return if account_name.blank? || account_name.match?(/\A[\w.]+\z/)

    errors.add(:account_name, 'はアンダースコアとピリオド以外の特殊文字を使用できません。')
  end

  def no_consecutive_periods
    return unless account_name&.include?('..')

    errors.add(:account_name, 'にピリオドを2つ連続して使用することはできません。')
  end
end
