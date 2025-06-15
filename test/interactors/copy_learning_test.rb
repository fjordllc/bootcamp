# frozen_string_literal: true

require 'test_helper'

class CopyLearningTest < ActiveSupport::TestCase
  def setup
    @user = users(:kimura)
    @from_practice = practices(:practice1)
    @to_practice = practices(:practice2)

    # Clear any existing data
    @user.learnings.destroy_all
  end

  test 'successfully copies learning when original exists and target does not' do
    # Create original learning
    Learning.create!(
      user: @user,
      practice: @from_practice,
      status: 'complete'
    )

    result = CopyLearning.call(
      user: @user,
      from_practice: @from_practice,
      to_practice: @to_practice
    )

    assert result.success?
    assert_equal 'Learning copied successfully', result.message
    assert_not_nil result.copied_learning

    # Verify the copied learning was created
    copied_learning = Learning.find_by(user: @user, practice: @to_practice)
    assert_not_nil copied_learning
    assert_equal 'complete', copied_learning.status
  end

  test 'skips copy when target learning already exists' do
    # Create both original and target learnings
    Learning.create!(user: @user, practice: @from_practice, status: 'complete')
    existing_learning = Learning.create!(user: @user, practice: @to_practice, status: 'started')

    result = CopyLearning.call(
      user: @user,
      from_practice: @from_practice,
      to_practice: @to_practice
    )

    assert result.success?
    assert_equal 'Learning already exists, skipping copy', result.message
    assert_equal existing_learning, result.existing_learning

    # Verify the existing learning was not modified
    existing_learning.reload
    assert_equal 'started', existing_learning.status
  end

  test 'fails when original learning does not exist' do
    result = CopyLearning.call(
      user: @user,
      from_practice: @from_practice,
      to_practice: @to_practice
    )

    assert_not result.success?
    assert_equal 'Original learning not found', result.error
  end

  test 'fails when required parameters are missing' do
    result = CopyLearning.call(
      user: nil,
      from_practice: @from_practice,
      to_practice: @to_practice
    )

    assert_not result.success?
    assert_equal 'Missing required parameters: user, from_practice, to_practice', result.error
  end

  test 'fails when learning creation fails' do
    # Create original learning
    Learning.create!(user: @user, practice: @from_practice, status: 'complete')

    # Mock Learning.create! to raise an exception
    Learning.stub :create!, ->(*) { raise ActiveRecord::RecordInvalid, Learning.new } do
      result = CopyLearning.call(
        user: @user,
        from_practice: @from_practice,
        to_practice: @to_practice
      )

      assert_not result.success?
      assert_match(/Failed to create learning/, result.error)
    end
  end
end
