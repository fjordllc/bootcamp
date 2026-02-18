# frozen_string_literal: true

require 'test_helper'
require 'active_decorator_test_case'

class PairWorkDecoratorTest < ActiveDecoratorTestCase
  test '#important?' do
    not_solved_pair_work = decorate(pair_works(:pair_work1))
    assert not_solved_pair_work.important?

    not_solved_pair_work.comments.create!(
      user: users(:komagata),
      description: 'コメント'
    )
    assert_not not_solved_pair_work.important?

    solved_pair_work = decorate(pair_works(:pair_work2))
    assert_not solved_pair_work.important?
  end
end
