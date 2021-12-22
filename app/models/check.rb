# frozen_string_literal: true

class Check < ApplicationRecord
  belongs_to :user
  belongs_to :checkable, polymorphic: true
  after_create CheckCallbacks.new
  after_destroy CheckCallbacks.new
  alias sender user

  validates :user_id, uniqueness: { scope: %i[checkable_id checkable_type] }

  def receiver
    checkable.user
  end
end
