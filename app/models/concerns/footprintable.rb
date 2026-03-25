# frozen_string_literal: true

module Footprintable
  extend ActiveSupport::Concern

  included do
    has_many :footprints, as: :footprintable, dependent: :destroy
  end
end
