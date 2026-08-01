# frozen_string_literal: true

module UserValidations7
  extend ActiveSupport::Concern

  included do
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
