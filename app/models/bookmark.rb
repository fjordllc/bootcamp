# frozen_string_literal: true

class Bookmark < ApplicationRecord
  belongs_to :bookmarkable, polymorphic: true
end
