# frozen_string_literal: true

class ActionCompletedButtonComponent < ViewComponent::Base
  def initialize(is_initial_action_completed:, commentable_id:)
    @is_action_completed = is_initial_action_completed
    @commentable_id = commentable_id
  end

  private

  attr_reader :is_action_completed, :commentable_id
end
