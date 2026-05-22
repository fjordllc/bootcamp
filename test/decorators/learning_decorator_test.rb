# frozen_string_literal: true

require 'test_helper'
require 'active_decorator_test_case'

class LearningDecoratorTest < ActiveDecoratorTestCase
  test '#completion_modal?' do
    learning = decorate(learnings(:learning16))

    def learning.current_user = user

    assert learning.completion_modal?
  end
end
