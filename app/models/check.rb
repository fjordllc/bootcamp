# frozen_string_literal: true

class Check < ApplicationRecord
  belongs_to :user
  belongs_to :checkable, polymorphic: true
  after_create_commit -> { CheckCallbacks.new.after_create(self) }
  after_destroy_commit -> { CheckCallbacks.new.after_destroy(self) }
  alias sender user

  validates :user_id, uniqueness: { scope: %i[checkable_id checkable_type] }

  def receiver
    checkable.respond_to?(:user) ? checkable.user : nil
  end
end
