# frozen_string_literal: true

class MicroReport < ApplicationRecord
  include Reactionable
  include Mentioner

  belongs_to :user
  belongs_to :comment_user, class_name: 'User'
  validates :content, presence: true

  before_validation :set_default_comment_user, on: :create

  mentionable_as :content
  alias sender comment_user

  def path
    Rails.application.routes.url_helpers.user_micro_reports_path(
      user,
      micro_report_id: id
    )
  end

  private

  def set_default_comment_user
    self.comment_user ||= user
  end
end
