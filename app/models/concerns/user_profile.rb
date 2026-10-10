# frozen_string_literal: true

# ユーザーのプロフィール表示・SNS連携に関する責務をまとめたもの。
module UserProfile
  extend ActiveSupport::Concern

  included do
    validates :name, presence: true
    validates :description, presence: true
    validates :show_mentor_profile, inclusion: { in: [true, false] }
    validates :show_study_streak, inclusion: { in: [true, false] }

    validates :facebook_url, :feed_url, :blog_url,
              format: {
                allow_blank: true,
                with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
                message: 'は「http://example.com」や「https://example.com」のようなURL形式で入力してください'
              }

    validate_name_kana
    validate_twitter_account
  end

  class_methods do
    private

    def validate_name_kana
      with_options if: -> { !validation_context.in?(%i[reset_password retirement training_completion]) } do
        validates :name_kana, presence: true,
                              format: {
                                with: /\A[\p{katakana}\p{blank}ー－]+\z/,
                                message: 'はスペースとカタカナのみが使用できます'
                              }
      end
    end

    def validate_twitter_account
      with_options if: -> { !validation_context.in?(%i[retirement training_completion]) } do
        validates :twitter_account,
                  length: { maximum: 15 },
                  allow_blank: true,
                  format: {
                    with: /\A\w+\z/,
                    message: 'は英文字と_（アンダースコア）のみが使用できます'
                  }
      end
    end
  end
end
