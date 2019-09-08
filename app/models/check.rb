# frozen_string_literal: true

class Check < ApplicationRecord
  belongs_to :user
  belongs_to :checkable, polymorphic: true
  after_create CheckCallbacks.new
  alias_method :sender, :user

  def receiver
    checkable.user
  end
end
