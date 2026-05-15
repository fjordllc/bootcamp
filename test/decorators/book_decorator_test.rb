# frozen_string_literal: true

require 'test_helper'
require 'active_decorator_test_case'

class BookDecoratorTest < ActiveDecoratorTestCase
  setup do
    @book1 = decorate(books(:book1))
    @book2 = decorate(books(:book2))
  end

  test '#must_read_for_any_practices?' do
    assert @book1.must_read_for_any_practices?
    assert_not @book2.must_read_for_any_practices?
  end
end
