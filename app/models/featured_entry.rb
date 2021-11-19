# frozen_string_literal: true

class FeaturedEntry < ApplicationRecord
  belongs_to :featureable, polymorphic: true
end
