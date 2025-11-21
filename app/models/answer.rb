# frozen_string_literal: true

class Answer < ApplicationRecord
  include Reactionable
  include Searchable
  include Mentioner

  belongs_to :user, touch: true
  belongs_to :question, touch: false
  alias sender user

  validates :description, presence: true
  validates :user, presence: true

  columns_for_keyword_search :description

  mentionable_as :description

  def self.ransackable_attributes(_auth_object = nil)
    %w[description created_at updated_at user_id question_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user question reactions]
  end

  def receiver
    question.user
  end

  def path
    Rails.application.routes.url_helpers.polymorphic_path(question, anchor:)
  end

  def certain_period_has_passed?
    created_at.since(1.week).to_date == Date.current
  end

  def search_title
    question&.title || 'Q&A回答'
  end

  def search_url
    return Rails.application.routes.url_helpers.questions_path unless question.presence

    Rails.application.routes.url_helpers.question_path(question, anchor: "answer_#{id}")
  end
end
