# frozen_string_literal: true

require 'test_helper'

class ActionCompletedButtonComponentTest < ViewComponent::TestCase
  test 'action is completed' do
    # update_pathとmodel_nameは使用されないため値は任意
    render_inline(ActionCompletedButtonComponent.new(is_initial_action_completed: true, update_path: '/api/talks/1', model_name: 'talk'))

    assert_text '対応済です'
  end

  test 'action is not completed' do
    render_inline(ActionCompletedButtonComponent.new(is_initial_action_completed: false, update_path: '/api/talks/1', model_name: 'talk'))

    assert_text '対応済にする'
  end
end
