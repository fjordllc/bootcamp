# frozen_string_literal: true

require 'application_system_test_case'

class GlobalNavigationTest < ApplicationSystemTestCase
  test 'administrator can see unreplied talk count' do
    visit_with_auth root_path, 'komagata'
    within '.unreplied-talk-count' do
      assert_text '1'
    end
  end

  test 'mentor can not see unreplied talk count' do
    visit_with_auth root_path, 'mentormentaro'
    assert_no_selector '.unreplied-talk-count'
  end

  test 'advisor can not see unreplied talk count' do
    visit_with_auth root_path, 'advijirou'
    assert_no_selector '.unreplied-talk-count'
  end

  test 'student can not see unreplied talk count' do
    visit_with_auth root_path, 'kimura'
    assert_no_selector '.unreplied-talk-count'
  end
end
