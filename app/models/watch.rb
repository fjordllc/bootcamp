# frozen_string_literal: true

class Watch < ApplicationRecord
  include Watchable
  belongs_to :user, touch: true
  belongs_to :watchable, polymorphic: true

  validates :user_id, uniqueness: { scope: %i[watchable_id watchable_type] }
  validates :watchable_type, :watchable_id, :user_id, presence: true
end
