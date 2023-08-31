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
              format: {
                with: /\A[\w\.]+\z/,
                message: 'はアンダースコアとピリオド以外の特殊文字を使用できません。'
              },
              format: {
                without: /\.\./,
                message: 'にピリオドを2つ連続して使用することはできません。'
              },
              length: {
                in: 2..32,
                message: 'は2文字以上32文字以内で入力してください。'
              }
  end
end
