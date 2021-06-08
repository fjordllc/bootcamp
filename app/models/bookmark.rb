# frozen_string_literal: true

class Bookmark < ApplicationRecord
  include Bookmarkable

  belongs_to :user
  # belongs_to :report
  belongs_to :bookmarkable, polymorphic: true
end
