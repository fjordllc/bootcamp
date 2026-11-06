# frozen_string_literal: true

require 'application_system_test_case'

module Answers
  class BestAnswerTest < ApplicationSystemTestCase
    include ActiveJob::TestHelper

    setup do
      @delivery_mode = AbstractNotifier.delivery_mode
      AbstractNotifier.delivery_mode = :normal
    end

    teardown do
      AbstractNotifier.delivery_mode = @delivery_mode
    end

    test 'selection waits for the response and preserves unsaved inputs' do
      answer = answers(:answer1)
      other = answers(:answer2)
      visit_with_auth question_path(answer.question), 'komagata'
      fill_in 'js-new-comment', with: '新規投稿の下書き'
      within "#answer_#{other.id}" do
        click_on '内容修正'
        fill_in 'answer[description]', with: '別回答の編集中の文章'
      end
      page.execute_script <<~JS
        window.originalBestAnswerFetch = window.fetch
        window.fetch = function(url, options) {
          if (new URL(url, location.href).pathname === '#{api_answer_correct_answer_path(answer)}') {
            return new Promise((resolve, reject) => {
              window.releaseBestAnswerFetch = () => window.originalBestAnswerFetch(url, options).then(resolve, reject)
            })
          }
          return window.originalBestAnswerFetch(url, options)
        }
      JS
      within "#answer_#{answer.id}" do
        accept_confirm { click_button 'ベストアンサーにする' }
        assert_button 'ベストアンサーにする', disabled: true
      end
      assert_selector '.js-solved-status', text: '未解決'
      assert_no_selector "#answer_badge_#{answer.id}.correct-answer"
      page.execute_script('window.releaseBestAnswerFetch(); window.fetch = window.originalBestAnswerFetch')
      assert_selector '.js-solved-status', text: '解決済'
      assert_selector "#answer_badge_#{answer.id}.correct-answer"
      assert_field 'js-new-comment', with: '新規投稿の下書き'
      within("#answer_#{other.id}") { assert_field 'answer[description]', with: '別回答の編集中の文章' }
      within "#answer_#{answer.id}" do
        accept_confirm { click_button 'ベストアンサーを取り消す' }
      end
      assert_selector '.js-solved-status', text: '未解決'
      assert_field 'js-new-comment', with: '新規投稿の下書き'
      within("#answer_#{other.id}") { assert_field 'answer[description]', with: '別回答の編集中の文章' }
    end

    test 'failed selection and cancellation preserve the display and allow retry' do
      answer = answers(:answer1)
      visit_with_auth question_path(answer.question), 'komagata'
      %w[ベストアンサーにする ベストアンサーを取り消す].each_with_index do |label, index|
        page.execute_script <<~JS
          window.originalBestAnswerFetch = window.fetch
          const answer = document.querySelector('#answer_#{answer.id}')
          delete answer.dataset.bestAnswerResult
          answer.addEventListener('turbo:submit-end', (event) => {
            answer.dataset.bestAnswerResult = event.detail.success ? 'success' : 'failure'
          }, { once: true })
          window.fetch = function(url, options) {
            if (new URL(url, location.href).pathname === '#{api_answer_correct_answer_path(answer)}') {
              return Promise.reject(new TypeError('Network failure'))
            }
            return window.originalBestAnswerFetch(url, options)
          }
        JS
        within("#answer_#{answer.id}") { accept_confirm { click_button label } }
        assert_selector "#answer_#{answer.id}[data-best-answer-result='failure']"
        assert_selector '.js-solved-status', exact_text: index.zero? ? '未解決' : '解決済'
        within("#answer_#{answer.id}") { assert_button label, disabled: false }
        assert_no_selector '.swal2-toast.is-error'
        if index.zero?
          assert_nil answer.reload.type
        else
          assert_equal 'CorrectAnswer', answer.reload.type
        end
        page.execute_script('window.fetch = window.originalBestAnswerFetch')
        within("#answer_#{answer.id}") { accept_confirm { click_button label } }
        assert_selector '.js-solved-status', exact_text: index.zero? ? '解決済' : '未解決'
      end
    end

    test "admin can resolve user's question" do
      visit_with_auth "/questions/#{questions(:question2).id}", 'komagata'
      assert_text 'ベストアンサーにする'
      accept_alert do
        click_button 'ベストアンサーにする'
      end
      assert_no_text 'ベストアンサーにする'
    end

    test 'delete best answer' do
      visit_with_auth "/questions/#{questions(:question2).id}", 'komagata'
      accept_alert do
        click_button 'ベストアンサーにする'
      end
      accept_alert do
        click_button 'ベストアンサーを取り消す'
      end
      assert_text 'ベストアンサーにする'
    end

    test 'notify watchers of best answer' do
      visit_with_auth "/questions/#{questions(:question2).id}", 'sotugyou'

      assert_difference 'ActionMailer::Base.deliveries.count', 1 do
        perform_enqueued_jobs do
          assert_no_text '解決済'
          accept_alert do
            click_button 'ベストアンサーにする'
          end
          assert_text '解決済'
        end
      end

      # Watcherに通知される
      visit_with_auth '/notifications?status=unread', 'kimura'
      assert_text 'sotugyouさんの質問【 injectとreduce 】でkomagataさんの回答がベストアンサーに選ばれました。'

      # Watchしていない回答者には通知されない
      visit_with_auth '/notifications?status=unread', 'komagata'
      assert_no_text 'sotugyouさんの質問【 injectとreduce 】でkomagataさんの回答がベストアンサーに選ばれました。'

      # 質問者には通知されない
      visit_with_auth '/notifications?status=unread', 'sotugyou'
      assert_no_text 'sotugyouさんの質問【 injectとreduce 】でkomagataさんの回答がベストアンサーに選ばれました。'
    end
  end
end
