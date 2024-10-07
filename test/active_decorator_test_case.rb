# frozen_string_literal: true

require 'test_helper'
require 'supports/decorator_helper'

class ActiveDecoratorTestCase < ActiveSupport::TestCase
  include ActionView::TestCase::Behavior
  include DecoratorHelper

  setup do
    ActiveDecorator::ViewContext.push(controller.view_context)
  end
end
