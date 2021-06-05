class Bookmark < ApplicationRecord
  belongs_to :bookmarkable, polymorphic: true
end
