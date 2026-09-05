# frozen_string_literal: true

# ユーザーの新規登録(入会)に関する責務をまとめたもの。
module UserRegistration
  extend ActiveSupport::Concern

  included do
    scope :classmates, lambda { |start_date, end_date|
      where(created_at: start_date..end_date).order(:created_at, :id)
    }
    scope :campaign, -> { where(created_at: Campaign.recently_campaign) }

    with_options if: -> { %i[create update].include? validation_context } do
      validates :login_name, presence: true, uniqueness: true,
                             format: {
                               with: /\A[a-z\d](?:[a-z\d]|-(?=[a-z\d]))*\z/i,
                               message: 'は半角英数字と-（ハイフン）のみが使用できます 先頭と最後にハイフンを使用することはできません ハイフンを連続して使用することはできません'
                             }
    end

    with_options if: -> { !validation_context.in?(%i[reset_password retirement training_completion]) } do
      validates :name_kana, presence: true,
                            format: {
                              with: /\A[\p{katakana}\p{blank}ー－]+\z/,
                              message: 'はスペースとカタカナのみが使用できます'
                            }
    end

    with_options if: -> { !status.staff? && !validation_context.in?(%i[reset_password retirement training_completion]) } do
      validates :job, presence: true
    end

    with_options if: -> { !adviser? && !validation_context.in?(%i[reset_password retirement training_completion]) } do
      validates :os, presence: true
    end
  end
end
