# frozen_string_literal: true

require 'test_helper'

class BookDecoratorTest < ActiveSupport::TestCase
  setup do
    @book1 = ActiveDecorator::Decorator.instance.decorate(books(:book1))
    @book2 = ActiveDecorator::Decorator.instance.decorate(books(:book2))
  end

  test '#must_read_for_any_practices?' do
    assert_equal true, @book1.must_read_for_any_practices?
    assert_equal false, @book2.must_read_for_any_practices?
  end
end
