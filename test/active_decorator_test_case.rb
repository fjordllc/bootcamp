# frozen_string_literal: true

require 'test_helper'

class ActiveDecoratorTestCase < ActiveSupport::TestCase
  include ActionView::TestCase::Behavior

  setup do
    ActiveDecorator::ViewContext.push(controller.view_context)
  end

  private

  def decorate(instance)
    ActiveDecorator::Decorator.instance.decorate(instance)
  end
end
