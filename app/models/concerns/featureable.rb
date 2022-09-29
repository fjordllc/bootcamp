# frozen_string_literal: true

module Featureable
  extend ActiveSupport::Concern

  included do
    has_many :featured_entries, as: :featureable, dependent: :destroy
  end
end
