# frozen_string_literal: true

require 'application_system_test_case'

class CodingTestsTest < ApplicationSystemTestCase
  setup do
    @coding_test = coding_tests(:coding_test1)
    @practice = @coding_test.practice
    @coding_test_submissions = coding_test_submissions(:coding_test_submission1)
  end

  test 'create a coding_test_submission' do
    visit_with_auth "/coding_tests/#{@coding_test.id}", 'hajime'

    code = <<~CODE
      console.log('hello');
    CODE

    ace_editor = find('.ace_text-input', visible: false)
    ace_editor.set(code)

    accept_alert do
      click_button '実行'
    end

    assert_current_path "/practices/#{@practice.id}"
  end
end
