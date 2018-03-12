class Check < ApplicationRecord
  belongs_to :user
  belongs_to :checkable, polymorphic: true
  after_create CheckCallbacks.new
  alias_method :sender, :user

  def reciever
    checkable.user
  end
end
