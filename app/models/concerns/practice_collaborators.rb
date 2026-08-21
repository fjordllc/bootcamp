# frozen_string_literal: true

module PracticeCollaborators
  extend ActiveSupport::Concern

  def text
    PracticeText.new(self)
  end

  def learner_record
    PracticeLearnerRecord.new(self)
  end

  def quiz_gate
    PracticeQuizGate.new(self)
  end

  def must_read_books
    PracticeMustReadBooks.new(self)
  end

  def category_resolver
    PracticeCategoryResolver.new(self)
  end
end
