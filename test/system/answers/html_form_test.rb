# frozen_string_literal: true

require 'application_system_test_case'

module Answers
  class HTMLFormTest < ApplicationSystemTestCase
    driven_by :playwright,
              screen_size: [1440, 1000],
              options: {
                name: :playwright_without_javascript,
                browser_type: :chromium,
                chromiumSandbox: false,
                headless: ENV['HEADFUL'] != '1',
                playwright_cli_executable_path: './node_modules/.bin/playwright',
                javaScriptEnabled: false
              }

    test 'post and correct an invalid answer without JavaScript' do
      question = questions(:question2)
      visit_with_auth question_path(question), 'komagata'
      count = question.answers.count
      assert_no_selector '.loading-content'
      assert_selector '.answer-content'
      assert_button 'コメントする', disabled: false

      fill_in 'js-new-comment', with: '   '
      click_button 'コメントする'
      assert_text '入力内容にエラーがありました'
      assert_field 'js-new-comment', with: '   '
      assert_selector '.answers-list .answer', count: count
      assert_no_selector '.loading-content'

      fill_in 'js-new-comment', with: 'JavaScriptなしで投稿した回答'
      click_button 'コメントする'
      assert_current_path question_path(question), ignore_query: true
      assert_text '回答を投稿しました！'
      assert_selector '.answer-text', text: 'JavaScriptなしで投稿した回答'
      assert_selector '.answers-list .answer', count: count + 1
      assert_selector '.js-answer-count', exact_text: (count + 1).to_s
      assert_field 'js-new-comment', with: ''

      page.refresh
      assert_selector '.answers-list .answer', count: count + 1
    end
  end
end
