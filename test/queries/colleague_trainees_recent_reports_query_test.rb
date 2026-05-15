# frozen_string_literal: true

require 'test_helper'

class ColleagueTraineesRecentReportsQueryTest < ActiveSupport::TestCase
  test 'should return colleague trainees recent reports' do
    user = users(:senpai)
    trainee_report = reports(:report11)
    other_report = reports(:report10)

    result = ColleagueTraineesRecentReportsQuery.new(current_user: user).call

    assert_includes result, trainee_report
    assert_not_includes result, other_report
  end

  test 'should exclude report with wip' do
    user = users(:senpai)
    wip_report = reports(:report75)

    result = ColleagueTraineesRecentReportsQuery.new(current_user: user).call

    assert_not_includes result, wip_report
  end

  test 'should be ordered by recent' do
    user = users(:senpai)

    result = ColleagueTraineesRecentReportsQuery.new(current_user: user).call

    dates = result.map(&:reported_on)
    assert_equal dates, dates.sort.reverse
  end
end
