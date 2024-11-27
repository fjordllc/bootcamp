# frozen_string_literal: true

class Talk < ApplicationRecord
  include Commentable
  include Bookmarkable
  include SearchHelper

  belongs_to :user

  paginates_per 20

  scope :action_uncompleted, -> { where(action_completed: false) }
end
