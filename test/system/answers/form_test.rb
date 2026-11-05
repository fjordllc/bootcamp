# frozen_string_literal: true

require 'application_system_test_case'

module Answers
  class FormTest < ApplicationSystemTestCase
    include ActiveJob::TestHelper

    setup do
      @delivery_mode = AbstractNotifier.delivery_mode
      AbstractNotifier.delivery_mode = :normal
    end

    teardown do
      AbstractNotifier.delivery_mode = @delivery_mode
    end

    test 'answer form in questions/:id has comment tab and preview tab' do
      visit_with_auth "/questions/#{questions(:question2).id}", 'komagata'
      within('.a-form-tabs') do
        assert_text 'コメント'
        assert_text 'プレビュー'
      end
    end

    test 'post new comment for question' do
      visit_with_auth "/questions/#{questions(:question2).id}", 'komagata'
      within('.thread-comment-form__form') do
        fill_in('answer[description]', with: 'test')
      end
      page.all('.a-form-tabs__tab.js-tabs__tab')[1].click
      assert_text 'test'
      click_button 'コメントする'
      assert_text 'test'
      assert_text 'Watch中'
    end

    test 'edit answer form has comment tab and preview tab' do
      visit_with_auth "/questions/#{questions(:question3).id}", 'komagata'
      within('.thread-comment:first-child') do
        click_button '内容修正'
        assert_text 'コメント'
        assert_text 'プレビュー'
      end
    end

    test 'clear preview after posting comment for question' do
      visit_with_auth "/questions/#{questions(:question2).id}", 'komagata'
      find('#js-new-comment').set('test')
      click_button 'コメントする'
      find('.thread-comment__description > div > p', text: 'test')
      find('.a-form-tabs__tab.js-tabs__tab', text: 'プレビュー').click
      within('#new-comment-preview') do
        assert_no_text :all, 'test'
      end
    end

    test 'post answers without reloading and use the newly connected controls' do
      question = questions(:question2)
      visit_with_auth question_path(question), 'komagata'
      count = question.answers.count
      page.execute_script('window.answerPageMarker = true')

      2.times do |index|
        within '.new-answer' do
          fill_in 'answer[description]', with: "**回答#{index}**"
          find('.answer-preview-tab').click
          assert_selector '#new-comment-preview strong', text: "回答#{index}"
          click_button 'コメントする'
        end
        assert_selector '.answers-list .answer', count: count + index + 1
        assert_selector '.js-answer-count', exact_text: (count + index + 1).to_s
        assert_field 'js-new-comment', with: ''
        assert_selector '.new-answer .edit-answer-tab.is-active'
        assert_selector '.new-answer #js-shortcut-post-comment[disabled]'
      end
      assert page.evaluate_script('window.answerPageMarker')
      assert_text 'Watch中'

      answer = question.answers.order(:id).last
      within "#answer_#{answer.id}" do
        assert_selector '.answer-text strong', text: '回答1'
        add_reaction('smile')
        assert_selector '.is-selected [data-reaction-kind="smile"].is-reacted'
        find('.is-selected [data-reaction-kind="smile"]').click
        assert_no_selector '.is-selected [data-reaction-kind="smile"].is-reacted'
        click_button '内容修正'
        fill_in 'answer[description]', with: '投稿後に編集'
        click_button '保存する'
        assert_text '投稿後に編集'
        accept_confirm { click_button 'ベストアンサーにする' }
        assert_selector '.best-answer-badge.correct-answer'
        accept_confirm { click_button 'ベストアンサーを取り消す' }
        assert_no_selector '.best-answer-badge.correct-answer'
        accept_confirm { click_button '削除する' }
      end
      assert_no_selector "#answer_#{answer.id}"
      assert_selector '.js-answer-count', exact_text: (count + 1).to_s
    end

    test 'invalid answer keeps input and can be corrected and posted' do
      question = questions(:question2)
      visit_with_auth question_path(question), 'komagata'
      count = question.answers.count

      within '.new-answer' do
        fill_in 'answer[description]', with: '   '
        click_button 'コメントする'
      end
      assert_text '入力内容にエラーがありました'
      within '.new-answer' do
        assert_field 'js-new-comment', with: '   '
        fill_in 'answer[description]', with: '修正した回答'
        click_button 'コメントする'
      end
      assert_selector '.answers-list .answer', count: count + 1
      assert_selector '.answer-text', text: '修正した回答'
      assert_no_selector '.new-answer .errors'
      assert_field 'js-new-comment', with: ''
    end

    test 'posting preserves another answer being edited' do
      question = questions(:question1)
      visit_with_auth question_path(question), 'komagata'
      answer = answers(:answer1)
      within "#answer_#{answer.id}" do
        click_button '内容修正'
        fill_in 'answer[description]', with: '編集中の回答'
      end
      within '.new-answer' do
        fill_in 'answer[description]', with: '追加する回答'
        click_button 'コメントする'
      end
      assert_selector '.answer-text', text: '追加する回答'
      within "#answer_#{answer.id}" do
        assert_field 'answer[description]', with: '編集中の回答'
      end
    end

    test 'first answer updates the zero count' do
      question = questions(:question4)
      visit_with_auth question_path(question), 'komagata'
      assert_selector '.js-answer-count.is-zero', exact_text: '0'
      fill_in 'js-new-comment', with: '最初の回答'
      click_button 'コメントする'
      assert_selector '.answer-text', text: '最初の回答'
      assert_selector '.js-answer-count:not(.is-zero)', exact_text: '1'
    end

    test 'image upload works after replacing the form' do
      visit_with_auth question_path(questions(:question4)), 'komagata'
      fill_in 'js-new-comment', with: 'フォームを更新する回答'
      click_button 'コメントする'
      assert_selector '.answer-text', text: 'フォームを更新する回答'
      assert_field 'js-new-comment', with: ''

      within '.new-answer' do
        attach_file Rails.root.join('test/fixtures/files/users-avatars-komagata.jpg'), make_visible: true
        assert_field 'js-new-comment', with: /<img src=/
        find('.answer-preview-tab').click
        assert_selector '#new-comment-preview img'
        click_button 'コメントする'
      end
      assert_selector '.answers-list .answer-text img'
    end

    test 'failed request preserves input and allows retry' do
      question = questions(:question2)
      visit_with_auth question_path(question), 'komagata'
      count = question.answers.count
      page.execute_script <<~JS
        window.originalAnswerFetch = window.fetch
        document.querySelector('.new-answer-container').addEventListener('turbo:submit-end', (event) => {
          event.currentTarget.dataset.submissionResult = event.detail.success ? 'success' : 'failure'
        }, { once: true })
        window.fetch = function(url, options) {
          if (new URL(url, location.href).pathname === '/api/answers') {
            return Promise.reject(new TypeError('Network failure'))
          }
          return window.originalAnswerFetch(url, options)
        }
      JS
      fill_in 'js-new-comment', with: '通信失敗後に再投稿'
      click_button 'コメントする'
      assert_selector '.new-answer-container[data-submission-result="failure"]'
      assert_no_selector '.swal2-toast.is-error'
      assert_field 'js-new-comment', with: '通信失敗後に再投稿'
      assert_button 'コメントする', disabled: false
      assert_selector '.js-answer-count', exact_text: count.to_s

      page.execute_script('window.fetch = window.originalAnswerFetch')
      click_button 'コメントする'
      assert_selector '.answer-text', text: '通信失敗後に再投稿'
      assert_selector '.js-answer-count', exact_text: (count + 1).to_s
    end

    test 'posting after Turbo navigation and history restoration does not duplicate handlers' do
      question = questions(:question2)
      visit_with_auth question_path(question), 'komagata'
      assert_selector '.answer-text'
      count = question.answers.count
      page.execute_script('window.answerPageMarker = true')
      page.execute_script <<~JS
        import('@hotwired/turbo-rails').then(({ Turbo }) => {
          Turbo.visit('#{question_path(questions(:question4))}')
        })
      JS
      assert_current_path question_path(questions(:question4))
      assert_field 'js-new-comment'
      page.go_back
      assert_current_path question_path(question), ignore_query: true
      assert_field 'js-new-comment'
      page.go_forward
      assert_current_path question_path(questions(:question4))
      assert_field 'js-new-comment'
      assert_no_selector '.loading-content'
      page.go_back
      assert_current_path question_path(question), ignore_query: true
      assert_field 'js-new-comment'
      assert page.evaluate_script('window.answerPageMarker')

      fill_in 'js-new-comment', with: '**履歴復元後の回答**'
      click_button 'コメントする'
      assert_selector '.answer-text strong', text: '履歴復元後の回答'
      assert_selector '.answers-list .answer', count: count + 1
      assert_selector '.js-answer-count', exact_text: (count + 1).to_s
      within '.answers-list .answer:last-child' do
        click_button '内容修正'
        assert_field 'answer[description]', with: '**履歴復元後の回答**'
        click_button 'キャンセル'
        assert_selector '.answer-display'
      end
    end

    test 'HTML fallback works when Turbo is disabled on the form' do
      question = questions(:question2)
      visit_with_auth question_path(question), 'komagata'
      count = question.answers.count
      page.execute_script("document.querySelector('.new-answer form').dataset.turbo = 'false'")
      fill_in 'js-new-comment', with: '   '
      click_button 'コメントする'
      assert_text '入力内容にエラーがありました'
      assert_current_path api_answers_path
      assert_field 'js-new-comment', with: '   '
      assert_selector '.answers-list .answer', count: count

      page.execute_script("document.querySelector('.new-answer form').dataset.turbo = 'false'")
      fill_in 'js-new-comment', with: '**HTML送信の回答**'
      click_button 'コメントする'
      assert_current_path question_path(question), ignore_query: true
      assert_text '回答を投稿しました！'
      assert_selector '.answer-text strong', text: 'HTML送信の回答'
      assert_selector '.answers-list .answer', count: count + 1
    end
  end
end
