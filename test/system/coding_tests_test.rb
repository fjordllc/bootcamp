# frozen_string_literal: true

require 'application_system_test_case'

class CodingTestsTest < ApplicationSystemTestCase
  setup do
    @coding_test = coding_tests(:coding_test1)
    @practice = @coding_test.practice
  end

  test 'show listing coding_tests' do
    visit_with_auth "/practices/#{@practice.id}/coding_tests", 'hatsuno'
    assert_equal "#{@practice.title}のコーディングテスト | FBC", title
  end

  test 'show a coding_tests' do
    visit_with_auth "/coding_tests/#{@coding_test.id}", 'hatsuno'
    assert_equal "#{@coding_test.title} | FBC", title
  end
end
