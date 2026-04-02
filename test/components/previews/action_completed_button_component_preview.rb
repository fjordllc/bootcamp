# frozen_string_literal: true

class ActionCompletedButtonComponentPreview < ViewComponent::Preview
  def default
    render(ActionCompletedButtonComponent.new(
      is_initial_action_completed: false,
      update_path: '/products/1/action_completed',
      model_name: 'product'
    ))
  end

  def completed
    render(ActionCompletedButtonComponent.new(
      is_initial_action_completed: true,
      update_path: '/products/1/action_completed',
      model_name: 'product'
    ))
  end
end
