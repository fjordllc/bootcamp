# frozen_string_literal: true

class MicroReport < ApplicationRecord
  include Reactionable
  include Mentioner

  belongs_to :user
  belongs_to :comment_user, class_name: 'User'
  validates :content, presence: true

  before_validation :set_default_comment_user, on: :create

  after_destroy MicroReportCallbacks.new

  mentionable_as :content
  alias sender comment_user

  scope :ordered, -> { order(created_at: :asc, id: :asc) }

  def self.page_number_for(scope:, target:, per_page:)
    per_page = per_page.to_i
    return nil if per_page <= 0

    ids = scope.ordered.ids
    index = ids.index(target.id)
    return nil unless index

    index / per_page + 1
  end

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
