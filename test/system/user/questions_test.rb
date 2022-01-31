# frozen_string_literal: true

require 'application_system_test_case'

class User::QuestionsTest < ApplicationSystemTestCase
  test 'show listing questions' do
    visit_with_auth "/users/#{users(:hatsuno).id}/questions", 'hatsuno'
    assert_equal 'hatsuno | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
