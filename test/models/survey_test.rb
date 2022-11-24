# frozen_string_literal: true

require 'test_helper'

class SurveyTest < ActiveSupport::TestCase
  setup do
    @survey = surveys(:survey1)
  end

  test 'survey1 is valid' do
    @survey.valid?
  end

  test "survey1 is invalid if title is null" do
    @survey.title = nil
    @survey.invalid?
  end

  test "survey1 is invalid if start_at is null" do
    @survey.start_at = nil
    @survey.invalid?
  end
  
  test "survey1 is invalid if end_at is null" do
    @survey.end_at = nil
    @survey.invalid?
  end
end
