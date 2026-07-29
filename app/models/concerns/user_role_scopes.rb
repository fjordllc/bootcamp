# frozen_string_literal: true

module UserRoleScopes
  extend ActiveSupport::Concern

  included do
    scope :advisers, -> { where(adviser: true) }
    scope :not_advisers, -> { where(adviser: false) }
  end
end
