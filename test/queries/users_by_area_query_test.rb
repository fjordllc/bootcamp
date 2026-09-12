# frozen_string_literal: true

require 'test_helper'

class UsersByAreaQueryTest < ActiveSupport::TestCase
  test 'call' do
    tokyo_users = [users(:adminonly), users(:machida), users(:kimura)]
    assert_equal UsersByAreaQuery.new(area: '東京都').call.to_a.sort, tokyo_users.sort
    america_users = [users(:neverlogin), users(:tom)]
    assert_equal UsersByAreaQuery.new(area: '米国').call.to_a.sort, america_users.sort
  end
end
