# frozen_string_literal: true

require 'browserless_system_test_case'

class CodingTestsBrowserlessTest < BrowserlessSystemTestCase
  setup do
    @coding_test = coding_tests(:coding_test1)
    @practice = @coding_test.practice
    @coding_test_submissions = coding_test_submissions(:coding_test_submission1)
  end

  test 'show listing coding_test_submissions' do
    visit_with_auth "/coding_tests/#{@coding_test.id}/coding_test_submissions", 'hatsuno'
    assert_equal "「#{@coding_test.title}」の回答 | FBC", title
  end

  test 'show a coding_test_submissions' do
    visit_with_auth "/coding_tests/#{@coding_test.id}/coding_test_submissions/#{@coding_test_submissions.id}", 'hatsuno'
    assert_equal "「#{@coding_test.title}」の回答コード | FBC", title
  end
end
