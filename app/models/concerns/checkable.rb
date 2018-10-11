# frozen_string_literal: true

module Checkable
  extend ActiveSupport::Concern

  included do
    has_many :checks, as: :checkable, dependent: :delete_all

    scope :checked, -> { joins(:checks) }
  end

  def checked?
    checks.present?
  end
end
