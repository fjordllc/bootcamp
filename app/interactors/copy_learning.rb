# frozen_string_literal: true

class CopyLearning
  include Interactor

  def call
    validate_inputs
    return if context.failure?

    find_original_learning
    return if context.failure?

    check_existing_learning
    return if existing_learning_found?

    create_copied_learning
  end

  private

  def validate_inputs
    return if context.user && context.from_practice && context.to_practice

    context.fail!(error: 'Missing required parameters: user, from_practice, to_practice')
  end

  def find_original_learning
    context.original_learning = Learning.find_by(
      user: context.user,
      practice: context.from_practice
    )

    return if context.original_learning

    context.fail!(error: 'Original learning not found')
  end

  def check_existing_learning
    context.existing_learning = Learning.find_by(
      user: context.user,
      practice: context.to_practice
    )
  end

  def existing_learning_found?
    if context.existing_learning
      context.message = 'Learning already exists, skipping copy'
      true
    else
      false
    end
  end

  def create_copied_learning
    context.copied_learning = Learning.create!(
      user: context.user,
      practice: context.to_practice,
      status: context.original_learning.status
    )

    context.message = 'Learning copied successfully'
  rescue ActiveRecord::RecordInvalid => e
    context.fail!(error: "Failed to create learning: #{e.message}")
  end
end
