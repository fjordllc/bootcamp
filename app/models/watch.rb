# frozen_string_literal: true

class Watch < ApplicationRecord
  belongs_to :user, touch: true
  belongs_to :watchable, polymorphic: true
end
