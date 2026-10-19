# frozen_string_literal: true

class PracticeQuizGate
  def initialize(practice)
    @practice = practice
  end

  def published_practice_quiz
    @practice.practice_quiz if @practice.practice_quiz&.published?
  end

  def practice_quiz_required?
    published_practice_quiz.present?
  end

  def practice_quiz_passed_by?(user)
    return true unless practice_quiz_required?

    published_practice_quiz.passed_by?(user)
  end

  def completable_by?(user)
    return true unless practice_quiz_required?
    return false unless practice_quiz_passed_by?(user)

    return true unless @practice.submission

    @practice.learner_record.product(user)&.checked?
  end
end
