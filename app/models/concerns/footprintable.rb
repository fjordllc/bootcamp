# frozen_string_literal: true

module Footprintable
  extend ActiveSupport::Concern

  included do
    has_many :footprints, as: :footprintable, dependent: :delete_all
  end
end
