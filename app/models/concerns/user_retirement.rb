# frozen_string_literal: true

# ユーザーの退会・研修修了に関する責務をまとめたもの。
module UserRetirement
  extend ActiveSupport::Concern

  included do
    has_many :hibernations, dependent: :destroy
    has_many :request_retirements, dependent: :destroy
    has_one :targeted_request_retirement, class_name: 'RequestRetirement', foreign_key: 'target_user_id', dependent: :destroy, inverse_of: :target_user

    enum :satisfaction, { excellent: 0, good: 1, average: 2, poor: 3, very_poor: 4 }, prefix: true
    flag :retire_reasons, %i[done necessity other_school time motivation curriculum support environment cost job_change training_end]

    with_options if: -> { validation_context.in?(%i[retirement training_completion]) } do
      validates :satisfaction, presence: true
    end

    with_options if: -> { trainee? } do
      validates :company_id, presence: true
    end
  end
end
