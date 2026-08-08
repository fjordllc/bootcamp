# frozen_string_literal: true

module UserRetirement
  extend ActiveSupport::Concern

  included do
    has_many :hibernations, dependent: :destroy
    has_many :request_retirements, dependent: :destroy
    has_one :targeted_request_retirement, class_name: 'RequestRetirement', foreign_key: 'target_user_id', dependent: :destroy, inverse_of: :target_user

    enum :satisfaction, {
      excellent: 0,
      good: 1,
      average: 2,
      poor: 3,
      very_poor: 4
    }, prefix: true

    with_options if: -> { validation_context.in?(%i[retirement training_completion]) } do
      validates :satisfaction, presence: true
    end

    with_options if: -> { trainee? } do
      validates :company_id, presence: true
    end

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
