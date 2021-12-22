# frozen_string_literal: true

require 'application_system_test_case'

class User::AnswersTest < ApplicationSystemTestCase
  test 'show listing answers' do
    visit_with_auth "/users/#{users(:sotugyou).id}/answers", 'sotugyou'
    assert_equal 'sotugyouの回答 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
