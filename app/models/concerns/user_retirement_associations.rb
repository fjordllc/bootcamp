# frozen_string_literal: true

module UserRetirementAssociations
  extend ActiveSupport::Concern

  included do
    has_many :hibernations, dependent: :destroy
    has_many :request_retirements, dependent: :destroy
    has_one :targeted_request_retirement, class_name: 'RequestRetirement', foreign_key: 'target_user_id', dependent: :destroy, inverse_of: :target_user
  end
end
