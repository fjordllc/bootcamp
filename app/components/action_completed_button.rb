# frozen_string_literal: true

class ActionCompletedButton < ViewComponent::Base
  attr_reader :is_action_completed, :commentable_id

  def initialize(is_initial_action_completed:, commentable_id:)
    @is_action_completed = is_initial_action_completed
    @commentable_id = commentable_id
  end

  def completed_label
    is_action_completed ? '対応済み' : '未対応'
  end
end
