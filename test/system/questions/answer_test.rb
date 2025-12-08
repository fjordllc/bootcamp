# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/mock_helper'

module Questions
  class AnswerTest < ApplicationSystemTestCase
    include MockHelper

    setup do
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
      mock_openai_chat_completion(content: 'Test AI response')
    end

    test 'permission decision best answer' do
      visit_with_auth new_question_path, 'kimura'
      within 'form[name=question]' do
        fill_in 'question[title]', with: 'テストの質問タイトル'
        fill_in 'question[description]', with: 'テストの質問です。'
        click_button '登録する'
      end
      fill_in 'answer[description]', with: 'アンサーテスト'
      click_button 'コメントする'
      within '.a-card.is-answer.answer-display' do
        assert_text '内容修正'
        assert_text 'ベストアンサーにする'
        assert_text '削除する'
      end

      visit_with_auth questions_path(target: 'not_solved'), 'komagata'
      click_on 'テストの質問タイトル'
      within '.a-card.is-answer.answer-display' do
        assert_text '内容修正'
        assert_text 'ベストアンサーにする'
        assert_text '削除する'
      end

      visit_with_auth questions_path(target: 'not_solved'), 'hatsuno'
      click_on 'テストの質問タイトル'
      within '.a-card.is-answer.answer-display' do
        assert_no_text '内容修正'
        assert_no_text 'ベストアンサーにする'
        assert_no_text '削除する'
      end
    end

    test "mentor's watch-button is automatically on when new question is published" do
      visit_with_auth new_question_path, 'kimura'
      within 'form[name=question]' do
        fill_in 'question[title]', with: 'メンターのみ投稿された質問が"Watch中"になるテスト'
        fill_in 'question[description]', with: 'メンターのみ投稿された質問が"Watch中"になるテスト'
        click_button '登録する'
      end
      assert_text '質問を作成しました。'

      visit_with_auth questions_path(target: 'not_solved'), 'komagata'
      click_link 'メンターのみ投稿された質問が"Watch中"になるテスト'
      assert_text '削除する'
      assert_text 'Watch中'
    end

    test 'show number of comments' do
      visit_with_auth questions_path(target: 'not_solved'), 'kimura'
      assert_text 'コメント数表示テスト用の質問'
      element = all('.card-list-item').find { |component| component.has_text?('コメント数表示テスト用の質問') }
      within element do
        assert_selector '.a-meta', text: '（1）'
      end
    end

    test "show number of comments when comments don't exist" do
      visit_with_auth questions_path(target: 'not_solved'), 'kimura'
      assert_text 'テストの質問'

      element = all('.card-list-item').find { |component| component.has_text?('テストの質問') }
      within element do
        assert_selector '.a-meta.is-important', text: '（0）'
      end
    end
  end
end
