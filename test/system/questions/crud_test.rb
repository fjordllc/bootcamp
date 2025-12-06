# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/mock_helper'

module Questions
  class CrudTest < ApplicationSystemTestCase
    include MockHelper

    setup do
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
      mock_openai_chat_completion(content: 'Test AI response')
    end

    test 'create a question' do
      visit_with_auth new_question_path, 'kimura'
      within 'form[name=question]' do
        fill_in 'question[title]', with: 'テストの質問'
        fill_in 'question[description]', with: 'テストの質問です。'
        click_button '登録する'
      end
      assert_text '質問を作成しました。'
    end

    test 'update a question' do
      question = questions(:question8)
      visit_with_auth question_path(question), 'kimura'

      click_link '内容修正'
      fill_in 'question[title]', with: 'テストの質問（修正）'
      fill_in 'question[description]', with: 'テストの質問です。（修正）'
      within '.select-practices' do
        find('.choices__inner').click
        find('#choices--js-choices-practice-item-choice-12', text: 'sshdでパスワード認証を禁止にする').click
      end
      click_button '更新する'

      assert_text 'テストの質問（修正）'
      assert_text 'テストの質問です。（修正）'
      assert_selector 'a.a-category-link', text: 'sshdでパスワード認証を禁止にする'
      assert_selector 'a.a-side-nav__title-link', text: 'sshdでパスワード認証を禁止にする'
      assert_selector 'div.a-side-nav__item-title', text: 'プラクティス「sshdでパスワード認証を禁止にする」に関する質問'
    end

    test 'delete a question' do
      question = questions(:question8)
      visit_with_auth question_path(question), 'kimura'
      assert_text '削除申請'
    end

    test 'admin can update and delete any questions' do
      question = questions(:question8)
      visit_with_auth question_path(question), 'komagata'
      within '.page-content' do
        assert_text '内容修正'
        assert_text '削除'
      end
    end

    test 'not admin or not question author can not delete any questions' do
      question = questions(:question8)
      visit_with_auth question_path(question), 'hatsuno'
      within '.page-content' do
        assert_no_text '内容修正'
        assert_no_text '削除'
      end
    end
  end
end
