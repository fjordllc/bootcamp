# frozen_string_literal: true

class Talk < ApplicationRecord
  include Commentable
  include Bookmarkable

  belongs_to :user

  paginates_per 20

  scope :action_uncompleted, -> { where(action_completed: false) }

  def url
    Rails.application.routes.url_helpers.talk_path(self)
  end
end
