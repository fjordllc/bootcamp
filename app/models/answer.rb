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

  def receiver
    question.user
  end

  def path
    Rails.application.routes.url_helpers.polymorphic_path(question, anchor:)
  end

  def certain_period_has_passed?
    created_at.since(1.week).to_date == Date.current
  end

  def url
    Rails.application.routes.url_helpers.question_path(question, anchor: "answer_#{id}")
  end

  def formatted_summary(word)
    return description if word.blank?

    description.gsub(/(#{Regexp.escape(word)})/i, '<strong class="matched_word">\1</strong>')
  end
end
