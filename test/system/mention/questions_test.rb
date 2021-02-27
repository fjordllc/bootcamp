# frozen_string_literal: true

require 'application_system_test_case'

module Mention
  class QuestionsTest < ApplicationSystemTestCase
    setup do
      login_user 'kimura', 'testtest'
    end

    test 'mention from a question' do
      visit '/questions/new'
      fill_in 'question_title', with: 'テスト質問'
      fill_in 'question_description', with: '@hatsuno test'
      click_button '登録する'

      login_user 'hatsuno', 'testtest'
      visit '/notifications'
      assert_text 'kimuraさんからメンションがきました。'
    end
  end
end
