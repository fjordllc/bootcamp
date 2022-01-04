# frozen_string_literal: true

require 'application_system_test_case'

class User::AnswersTest < ApplicationSystemTestCase
  test 'show listing answers' do
    visit_with_auth "/users/#{users(:komagata).id}/answers", 'komagata'
    assert_equal 'komagataの回答 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
