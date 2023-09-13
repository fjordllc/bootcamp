# frozen_string_literal: true

class Talk < ApplicationRecord
  include Commentable
  include Bookmarkable

  belongs_to :user

  scope :action_uncompleted, -> { where(action_completed: false) }
end
