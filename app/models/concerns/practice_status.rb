# frozen_string_literal: true

module PracticeStatus
  extend ActiveSupport::Concern

    def status(user)
      learnings = Learning.where(
        user_id: user.id,
        practice_id: id
      )
      if learnings.blank?
        'unstarted'
      else
        learnings.first.status
      end
    end

    def status_by_learnings(learnings)
      learning = learnings.detect { |lerning| id == lerning.practice_id }
      learning&.status || 'unstarted'
    end

    def completed?(user)
      Learning.exists?(
        user:,
        practice_id: id,
        status: Learning.statuses[:complete]
      )
    end

    def published_practice_quiz
      practice_quiz if practice_quiz&.published?
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

      return true unless submission

      product(user)&.checked?
    end
end
