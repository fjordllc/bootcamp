# frozen_string_literal: true

module DecoratorHelper
  def auto_decorate(model)
    model.after_find { |record| DecoratorHelper.decorate(record) }
  end

  def decorate(instance)
    ActiveDecorator::Decorator.instance.decorate(instance)
  end

  module_function :decorate
end
