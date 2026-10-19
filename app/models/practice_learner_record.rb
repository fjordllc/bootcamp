# frozen_string_literal: true

class PracticeLearnerRecord
  def initialize(practice)
    @practice = practice
  end

  def status_by_learnings(learnings)
    learning = learnings.detect { |lerning| @practice.id == lerning.practice_id }
    learning&.status || 'unstarted'
  end

  def status(user)
    learnings = Learning.where(
      user_id: user.id,
      practice_id: @practice.id
    )
    if learnings.blank?
      'unstarted'
    else
      learnings.first.status
    end
  end

  def product(user)
    @practice.products.find_by(user:)
  end

  def exists_learning?(user)
    Learning.exists?(
      user:,
      practice_id: @practice.id
    )
  end

  def learning(user)
    @practice.learnings.find_by(user:)
  end

  def completed?(user)
    Learning.exists?(
      user:,
      practice_id: @practice.id,
      status: Learning.statuses[:complete]
    )
  end
end
