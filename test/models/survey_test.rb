# frozen_string_literal: true

require 'test_helper'

class SurveyTest < ActiveSupport::TestCase
  test 'before_start? returns true when current time is before start_at' do
    survey = surveys(:survey1)
    survey.start_at = Time.current + 1.day
    survey.end_at = Time.current + 2.days
    assert survey.before_start?
  end

  test 'before_start? returns false when current time is after start_at' do
    survey = surveys(:survey1)
    survey.start_at = Time.current - 1.day
    survey.end_at = Time.current + 1.day
    assert_not survey.before_start?
  end

  test 'answer_accepting? returns true when current time is between start_at and end_at' do
    survey = surveys(:survey1)
    survey.start_at = Time.current - 1.day
    survey.end_at = Time.current + 1.day
    assert survey.answer_accepting?
  end

  test 'answer_accepting? returns false when current time is before start_at' do
    survey = surveys(:survey1)
    survey.start_at = Time.current + 1.day
    survey.end_at = Time.current + 2.days
    assert_not survey.answer_accepting?
  end

  test 'answer_accepting? returns false when current time is after end_at' do
    survey = surveys(:survey1)
    survey.start_at = Time.current - 2.days
    survey.end_at = Time.current - 1.day
    assert_not survey.answer_accepting?
  end

  test 'answer_ended? returns true when current time is after end_at' do
    survey = surveys(:survey1)
    survey.start_at = Time.current - 2.days
    survey.end_at = Time.current - 1.day
    assert survey.answer_ended?
  end

  test 'answer_ended? returns false when current time is before end_at' do
    survey = surveys(:survey1)
    survey.start_at = Time.current - 1.day
    survey.end_at = Time.current + 1.day
    assert_not survey.answer_ended?
  end

  test 'answers? returns true when survey has answers' do
    survey = surveys(:survey1)
    user = users(:komagata)
    survey.survey_answers.create(user:)
    assert survey.answers?
  end

  test 'answers? returns false when survey has no answers' do
    survey = surveys(:survey1)
    survey.survey_answers.destroy_all
    assert_not survey.answers?
  end
end
