# frozen_string_literal: true

class DiscordProfile < ApplicationRecord
  belongs_to :user

  validates :times_url,
            format: {
              allow_blank: true,
              with: %r{\Ahttps://discord\.com/channels/\d+/\d+\z},
              message: 'はDiscordのチャンネルURLを入力してください'
            }
  with_options if: -> { validation_context != :retirement } do
    validates :account_name,
              format: {
                allow_blank: true,
                with: /\A[^\s\p{blank}].*[^\s\p{blank}]#\d{4}\z/,
                message: 'は「ユーザー名#４桁の数字」で入力してください'
              }
  end
end
