# frozen_string_literal: true

module LearningDecorator
  def should_display_message_automatically?(current_user:)
    user == current_user && complete? && !completion_message_displayed?
  end
end
