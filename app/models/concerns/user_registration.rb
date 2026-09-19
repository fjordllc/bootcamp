# frozen_string_literal: true

# ユーザーの新規登録(入会)に関する責務をまとめたもの。
module UserRegistration
  extend ActiveSupport::Concern

  included do
    after_create UserCallbacks.new

    scope :classmates, ->(start_date, end_date) { where(created_at: start_date..end_date).order(:created_at, :id) }
    scope :campaign, -> { where(created_at: Campaign.recently_campaign) }

    validates :nda, presence: true
  end
end
