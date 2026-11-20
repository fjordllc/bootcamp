# frozen_string_literal: true

require 'application_system_test_case'

module Answers
  class EditTest < ApplicationSystemTestCase
    test 'edit and cancel in place without changing the URL or saved answer' do
      answer = answers(:answer1)
      visit_with_auth question_path(answer.question), 'komagata'
      original_url = page.current_url
      within "#answer_#{answer.id}" do
        click_on '内容修正'
        assert_field 'answer[description]', with: answer.description
        fill_in 'answer[description]', with: '**未保存の文章**'
        find('.answer-preview-tab').click
        assert_selector '.markdown-preview strong', text: '未保存の文章'
        click_on 'キャンセル'
        assert_selector '.answer-display'
        assert_no_selector '.answer-editor'
        click_on '内容修正'
        assert_field 'answer[description]', with: answer.description
        assert_selector '.edit-answer-tab.is-active'
      end
      assert_equal original_url, page.current_url
      assert_equal 'atom一択です！', answer.reload.description
    end

    test 'successful edit updates only that answer and reconnects its controls' do
      answer = answers(:answer1)
      visit_with_auth question_path(answer.question), 'komagata'
      page.execute_script('window.answerEditMarker = true')
      within "#answer_#{answer.id}" do
        click_on '内容修正'
        fill_in 'answer[description]', with: '**保存した文章**'
        click_button '保存する'
      end
      assert_selector "#answer_#{answer.id} .answer-text strong", text: '保存した文章'
      within "#answer_#{answer.id}" do
        assert_selector '.answer-text strong', text: '保存した文章'
        assert_no_selector '.answer-editor'
        add_reaction('smile')
        assert_selector '.is-selected [data-reaction-kind="smile"].is-reacted'
        click_on '内容修正'
        assert_field 'answer[description]', with: '**保存した文章**'
        click_on 'キャンセル'
      end
      assert page.evaluate_script('window.answerEditMarker')
      assert_equal '**保存した文章**', answer.reload.description
    end

    test 'invalid edit keeps the editor open and preserves other unsaved inputs' do
      answer = answers(:answer1)
      other = answers(:answer2)
      visit_with_auth question_path(answer.question), 'komagata'
      fill_in 'js-new-comment', with: '新規投稿の下書き'
      within "#answer_#{other.id}" do
        click_on '内容修正'
        fill_in 'answer[description]', with: '別回答の編集中の文章'
      end
      within "#answer_#{answer.id}" do
        click_on '内容修正'
        fill_in 'answer[description]', with: '   '
        find('.answer-preview-tab').click
        click_button '保存する'
      end
      within "#answer_#{answer.id}" do
        assert_text '入力内容にエラーがありました'
        assert_field 'answer[description]', with: '   '
        assert_selector '.edit-answer-tab.is-active'
        assert_no_selector '.answer-display'
      end
      assert_equal 'atom一択です！', answer.reload.description
      assert_field 'js-new-comment', with: '新規投稿の下書き'
      within "#answer_#{other.id}" do
        assert_field 'answer[description]', with: '別回答の編集中の文章'
      end
      within "#answer_#{answer.id}" do
        click_on 'キャンセル'
        click_on '内容修正'
        assert_field 'answer[description]', with: answer.description
        assert_no_selector '.errors'
        fill_in 'answer[description]', with: '修正して保存'
        click_button '保存する'
      end
      assert_selector "#answer_#{answer.id} .answer-text", text: '修正して保存'
    end

    test 'failed request preserves editing input and can be retried without a toast' do
      answer = answers(:answer1)
      visit_with_auth question_path(answer.question), 'komagata'
      within "#answer_#{answer.id}" do
        click_on '内容修正'
        fill_in 'answer[description]', with: '通信失敗後に再保存'
      end
      page.execute_script <<~JS
        window.originalEditFetch = window.fetch
        document.querySelector('#answer_#{answer.id}').addEventListener('turbo:submit-end', (event) => {
          event.currentTarget.dataset.editResult = event.detail.success ? 'success' : 'failure'
        }, { once: true })
        window.fetch = function(url, options) {
          if (new URL(url, location.href).pathname === '#{api_answer_path(answer)}') {
            return Promise.reject(new TypeError('Network failure'))
          }
          return window.originalEditFetch(url, options)
        }
      JS
      within "#answer_#{answer.id}" do
        click_button '保存する'
      end
      assert_selector "#answer_#{answer.id}[data-edit-result='failure']"
      assert_no_selector '.swal2-toast.is-error'
      within "#answer_#{answer.id}" do
        assert_field 'answer[description]', with: '通信失敗後に再保存'
        assert_button '保存する', disabled: false
      end
      assert_equal 'atom一択です！', answer.reload.description
      page.execute_script('window.fetch = window.originalEditFetch')
      within "#answer_#{answer.id}" do
        click_button '保存する'
      end
      assert_selector "#answer_#{answer.id} .answer-text", text: '通信失敗後に再保存'
    end

    test 'edit URL cancels to the question and survives reloading' do
      answer = answers(:answer1)
      visit_with_auth question_path(answer.question, edit_answer_id: answer.id, anchor: "answer_#{answer.id}"), 'komagata'
      within "#answer_#{answer.id}" do
        assert_field 'answer[description]', with: answer.description
        fill_in 'answer[description]', with: '破棄する文章'
        click_on 'キャンセル'
      end
      assert_current_path question_path(answer.question), ignore_query: true
      assert_no_selector '.answers-list .answer-editor:not(.is-hidden)'
      page.refresh
      within "#answer_#{answer.id}" do
        click_on '内容修正'
        assert_field 'answer[description]', with: answer.description
      end
    end

    test 'Turbo history restoration reconnects edit controls without duplicate events' do
      answer = answers(:answer1)
      visit_with_auth question_path(answer.question), 'komagata'
      within "#answer_#{answer.id}" do
        click_on '内容修正'
        fill_in 'answer[description]', with: '履歴復元前の編集内容'
      end
      page.execute_script <<~JS
        import('@hotwired/turbo-rails').then(({ Turbo }) => {
          Turbo.visit('#{question_path(questions(:question2))}')
        })
      JS
      assert_current_path question_path(questions(:question2))
      assert_selector '.page-content-header__title', text: questions(:question2).title
      assert_field 'js-new-comment'
      page.go_back
      assert_current_path question_path(answer.question), ignore_query: true
      assert_selector '.page-content-header__title', text: answer.question.title
      within "#answer_#{answer.id}" do
        assert_field 'answer[description]', with: '履歴復元前の編集内容'
        click_on 'キャンセル'
        click_on '内容修正'
        assert_field 'answer[description]', with: answer.description
        fill_in 'answer[description]', with: '履歴復元後の編集内容'
        click_button '保存する'
      end
      assert_selector "#answer_#{answer.id} .answer-text", text: '履歴復元後の編集内容'
    end
  end
end
