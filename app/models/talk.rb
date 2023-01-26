# frozen_string_literal: true

class Talk < ApplicationRecord
  include Commentable
  include Bookmarkable

  belongs_to :user

  scope :unreplied, -> { where(unreplied: true) }
end
