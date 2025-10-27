# frozen_string_literal: true

class MicroReport < ApplicationRecord
  include Reactionable
  include Mentioner

  belongs_to :user
  validates :content, presence: true

  mentionable_as :content
  alias sender user

  def path
    Rails.application.routes.url_helpers.user_micro_reports_path(user)
  end
end
