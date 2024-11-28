# frozen_string_literal: true

class Answer < ApplicationRecord
  include Reactionable
  include Searchable
  include Mentioner
  include SearchHelper

  belongs_to :user, touch: true
  belongs_to :question, touch: false
  alias sender user

  validates :description, presence: true
  validates :user, presence: true

  columns_for_keyword_search :description

  mentionable_as :description

  def receiver
    question.user
  end

  def path
    Rails.application.routes.url_helpers.polymorphic_path(question, anchor:)
  end

  def certain_period_has_passed?
    created_at.since(1.week).to_date == Date.current
  end
end
