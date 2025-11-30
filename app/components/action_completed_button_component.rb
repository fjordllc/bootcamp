# frozen_string_literal: true

class ActionCompletedButtonComponent < ViewComponent::Base
  def initialize(is_initial_action_completed:, update_path:, model_name:)
    @is_action_completed = is_initial_action_completed
    @update_path = update_path
    @model_name = model_name
  end

  private

  attr_reader :is_action_completed, :update_path, :model_name
end
