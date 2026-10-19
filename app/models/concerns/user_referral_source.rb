# frozen_string_literal: true

# ユーザーがブートキャンプをどこで知ったか(入会経路)に関する責務をまとめたもの。
module UserReferralSource
  extend ActiveSupport::Concern

  included do
    enum :referral_source, { search_engine: 0, referral: 1, event: 2, x: 3, facebook: 4, blog: 5, web_ad: 6, other: 99 }, prefix: true

    validates :other_referral_source, presence: true, if: -> { referral_source == 'other' }
  end
end
