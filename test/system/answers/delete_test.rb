# frozen_string_literal: true

require 'application_system_test_case'

module Answers
  class DeleteTest < ApplicationSystemTestCase
    test 'cancel and delete an answer without losing another editor or the new draft' do
      answer = answers(:answer1)
      question = answer.question
      other = Answer.create!(question: question, user: users(:komagata), description: '残す回答')
      count = question.answers.count
      visit_with_auth question_path(question), 'komagata'
      within "#answer_#{other.id}" do
        click_on '内容修正'
        fill_in 'answer[description]', with: '編集中の下書き'
      end
      fill_in 'js-new-comment', with: '新規回答の下書き'
      dismiss_confirm do
        within("#answer_#{answer.id}") { click_button '削除する' }
      end
      assert_selector "#answer_#{answer.id}"
      accept_confirm do
        within("#answer_#{answer.id}") { click_button '削除する' }
      end
      assert_no_selector "#answer_#{answer.id}"
      assert_selector '.js-answer-count', exact_text: (count - 1).to_s
      assert_field 'js-new-comment', with: '新規回答の下書き'
      within("#answer_#{other.id}") { assert_field 'answer[description]', with: '編集中の下書き' }
    end

    test 'failed request preserves the answer and count and allows retry without a toast' do
      answer = correct_answers(:correct_answer1)
      question = answer.question
      count = question.answers.count
      visit_with_auth question_path(question), 'komagata'
      page.execute_script <<~JS
        window.originalDeleteFetch = window.fetch
        document.querySelector('#answer_#{answer.id}').addEventListener('turbo:submit-end', (event) => {
          event.currentTarget.dataset.deleteResult = event.detail.success ? 'success' : 'failure'
        }, { once: true })
        window.fetch = function(url, options) {
          if (new URL(url, location.href).pathname === '#{api_answer_path(answer)}') {
            return Promise.reject(new TypeError('Network failure'))
          }
          return window.originalDeleteFetch(url, options)
        }
      JS
      accept_confirm do
        within("#answer_#{answer.id}") { click_button '削除する' }
      end
      assert_selector "#answer_#{answer.id}[data-delete-result='failure']"
      assert_selector '.js-answer-count', exact_text: count.to_s
      assert_selector '.js-solved-status', text: '解決済'
      assert_no_selector '.swal2-toast.is-error'
      within("#answer_#{answer.id}") { assert_button '削除する', disabled: false }
      assert Answer.exists?(answer.id)
      page.execute_script('window.fetch = window.originalDeleteFetch')
      accept_confirm do
        within("#answer_#{answer.id}") { click_button '削除する' }
      end
      assert_no_selector "#answer_#{answer.id}"
      assert_selector '.js-answer-count', exact_text: (count - 1).to_s
    end

    test 'deleting the best answer restores controls that can still select and cancel a best answer' do
      answer = correct_answers(:correct_answer1)
      other = Answer.create!(question: answer.question, user: users(:komagata), description: '次の候補')
      visit_with_auth question_path(answer.question), 'komagata'
      accept_confirm do
        within("#answer_#{answer.id}") { click_button '削除する' }
      end
      assert_no_selector "#answer_#{answer.id}"
      assert_selector '.js-solved-status', text: '未解決'
      within "#answer_#{other.id}" do
        accept_confirm { click_button 'ベストアンサーにする' }
      end
      assert_selector '.js-solved-status', text: '解決済'
      within "#answer_#{other.id}" do
        accept_confirm { click_button 'ベストアンサーを取り消す' }
      end
      assert_selector '.js-solved-status', text: '未解決'
    end
  end
end
