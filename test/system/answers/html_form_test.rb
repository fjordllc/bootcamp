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

    test 'edit and correct an answer in the question page without JavaScript' do
      answer = answers(:answer1)
      visit_with_auth question_path(answer.question), 'komagata'
      within "#answer_#{answer.id}" do
        click_on '内容修正'
      end
      assert_current_path question_path(answer.question, edit_answer_id: answer.id)
      within "#answer_#{answer.id}" do
        assert_field 'answer[description]', with: answer.description
        fill_in 'answer[description]', with: '   '
        click_button '保存する'
      end
      assert_current_path api_answer_path(answer)
      within "#answer_#{answer.id}" do
        assert_text '入力内容にエラーがありました'
        assert_field 'answer[description]', with: '   '
      end
      assert_field 'js-new-comment', with: ''
      assert_equal 'atom一択です！', answer.reload.description
      within "#answer_#{answer.id}" do
        fill_in 'answer[description]', with: 'HTMLで編集した回答'
        click_button '保存する'
      end
      assert_current_path question_path(answer.question)
      assert_selector "#answer_#{answer.id} .answer-text", text: 'HTMLで編集した回答'
      assert_no_selector "#answer_editor_#{answer.id}:not(.is-hidden)"
    end

    test 'cancel after an HTML validation error returns to the saved answer' do
      answer = answers(:answer1)
      visit_with_auth question_path(answer.question, edit_answer_id: answer.id), 'komagata'
      within "#answer_#{answer.id}" do
        fill_in 'answer[description]', with: '   '
        click_button '保存する'
      end
      assert_text '入力内容にエラーがありました'
      within "#answer_#{answer.id}" do
        click_on 'キャンセル'
      end
      assert_current_path question_path(answer.question)
      assert_selector "#answer_#{answer.id} .answer-text", text: answer.description
      assert_no_selector "#answer_editor_#{answer.id}:not(.is-hidden)"
    end
  end
end
