# frozen_string_literal: true

module DecoratorHelper
  def self.auto_decorate(model)
    model.after_find { |record| ActiveDecorator::Decorator.instance.decorate(record) }
  end
end
