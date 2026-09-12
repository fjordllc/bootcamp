# frozen_string_literal: true

# ユーザーのDiscordアカウント連携に関する責務をまとめたもの。
module UserDiscordIntegration
  extend ActiveSupport::Concern

  included do
    has_one :discord_profile, dependent: :destroy
    accepts_nested_attributes_for :discord_profile, allow_destroy: true
  end
end
