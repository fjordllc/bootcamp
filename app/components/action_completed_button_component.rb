# frozen_string_literal: true

class ActionCompletedButtonComponent < ViewComponent::Base
  attr_reader :is_action_completed, :commentable_id

  def initialize(is_initial_action_completed:, commentable_id:)
    @is_action_completed = is_initial_action_completed
    @commentable_id = commentable_id
  end
end
