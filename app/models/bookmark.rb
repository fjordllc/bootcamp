# frozen_string_literal: true

class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :bookmarkable, polymorphic: true

  validates :user_id, uniqueness: { scope: %i[bookmarkable_id bookmarkable_type] }

  def display_date
    if bookmarkable_type == 'Report'
      bookmarkable.reported_on
    else
      bookmarkable.created_at
    end
  end
end
