# frozen_string_literal: true

module UserRetirementValidations
  extend ActiveSupport::Concern

  included do
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
