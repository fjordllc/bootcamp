# frozen_string_literal: true

require 'application_system_test_case'

class Practice::QuestionsTest < ApplicationSystemTestCase
  test 'show listing questions' do
    visit_with_auth "/practices/#{practices(:practice1).id}/questions", 'hatsuno'
    assert_equal 'OS X Mountain Lionをクリーンインストールする | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
