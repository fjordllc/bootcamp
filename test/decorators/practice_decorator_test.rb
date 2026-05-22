# frozen_string_literal: true

require 'test_helper'
require 'active_decorator_test_case'

class PracticeDecoratorTest < ActiveDecoratorTestCase
  test '#submission_answer_button?' do
    practice = decorate(practices(:practice1))
    practice.submission_answer = nil

    assert practice.submission_answer_button?(users(:mentormentaro))
    assert_not practice.submission_answer_button?(users(:kimura))
  end
end
