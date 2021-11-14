class FeaturedEntry < ApplicationRecord
  belongs_to :featureable, polymorphic: true
end
