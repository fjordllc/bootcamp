# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/mock_helper'

module Questions
  class WipTest < ApplicationSystemTestCase
    include MockHelper

    setup do
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
      mock_openai_chat_completion(content: 'Test AI response')
    end

    test 'create a question through wip' do
      visit_with_auth new_question_path, 'kimura'
      within 'form[name=question]' do
        fill_in 'question[title]', with: 'テストの質問'
        fill_in 'question[description]', with: 'テストの質問です。'
        click_button 'WIP'
      end
      assert_text '質問をWIPとして保存しました。'

      click_button '質問を公開'
      assert_text '質問を更新しました。'

      click_link '内容修正'
      click_button 'WIP'
      assert_text '質問をWIPとして保存しました。'
    end

    test 'create a WIP question' do
      visit_with_auth new_question_path, 'kimura'
      within 'form[name=question]' do
        fill_in 'question[title]', with: 'WIPタイトル'
        fill_in 'question[description]', with: 'WIP本文'
      end
      click_button 'WIP'
      assert_text '質問をWIPとして保存しました。'
    end

    test 'update a WIP question as WIP' do
      question = questions(:question_for_wip)
      visit_with_auth question_path(question), 'kimura'
      click_link '内容修正'
      within 'form[name=question]' do
        fill_in 'question[title]', with: '更新されたWIPタイトル'
        fill_in 'question[description]', with: '更新されたWIP本文'
      end
      click_button 'WIP'
      assert_text '質問をWIPとして保存しました。'
    end

    test 'update a WIP question as published' do
      question = questions(:question_for_wip)
      visit_with_auth question_path(question), 'kimura'
      click_link '内容修正'
      within 'form[name=question]' do
        fill_in 'question[title]', with: '更新されたタイトル'
        fill_in 'question[description]', with: '更新された本文'
      end
      click_button '質問を公開'
      assert_selector '.a-title-label.is-solved.is-danger', text: '未解決'
    end

    test 'update a published question as WIP' do
      question = questions(:question8)
      visit_with_auth question_path(question), 'kimura'
      click_link '内容修正'
      within 'form[name=question]' do
        fill_in 'question[title]', with: '更新されたWIPタイトル'
        fill_in 'question[description]', with: '更新されたWIP本文'
      end
      click_button 'WIP'
      assert_text '質問をWIPとして保存しました。'
    end

    test 'show a WIP question on the All Q&A list page' do
      visit_with_auth questions_path, 'kimura'
      assert_text 'wipテスト用の質問(wip中)'
      element = all('.card-list-item').find { |component| component.has_text?('wipテスト用の質問(wip中)') }
      within element do
        assert_selector '.a-list-item-badge.is-wip', text: 'WIP'
      end
    end

    test 'not show a WIP question on the unsolved Q&A list page' do
      visit_with_auth questions_path(target: 'not_solved'), 'kimura'
      assert_no_text 'wipテスト用の質問(wip中)'
      assert_selector 'h2', text: 'Q&A'
    end

    test "mentor's watch-button is not automatically on when new question is created as WIP" do
      visit_with_auth new_question_path, 'kimura'
      within 'form[name=question]' do
        fill_in 'question[title]', with: 'WIPタイトル'
        fill_in 'question[description]', with: 'WIP本文'
      end
      click_button 'WIP'
      assert_text '質問をWIPとして保存しました。'

      visit_with_auth questions_path, 'komagata'
      click_link 'WIPタイトル'
      assert_text '削除する'
      assert_no_text 'Watch中'
    end

    test "mentor's watch-button is automatically on when WIP question is updated as published" do
      visit_with_auth new_question_path, 'kimura'
      within 'form[name=question]' do
        fill_in 'question[title]', with: 'WIPタイトル'
        fill_in 'question[description]', with: 'WIP本文'
        click_button 'WIP'
      end
      assert_text '質問をWIPとして保存しました。'

      visit questions_path
      click_link 'WIPタイトル'
      assert_text '削除申請'
      click_link '内容修正'
      within 'form[name=question]' do
        fill_in 'question[title]', with: '更新されたタイトル'
        fill_in 'question[description]', with: '更新された本文'
        click_button '質問を公開'
      end
      assert_text '質問を更新しました'

      visit_with_auth questions_path(target: 'not_solved'), 'komagata'
      click_link '更新されたタイトル'
      assert_text '削除する'
      assert_text 'Watch中'
    end

    test 'should not notify to chat after wip a question' do
      visit_with_auth new_question_path, 'kimura'
      within 'form[name=question]' do
        fill_in 'question[title]', with: 'WIPタイトル'
        fill_in 'question[description]', with: 'WIP本文'
      end
      mock_log = []
      stub_info = proc { |i| mock_log << i }

      Rails.logger.stub(:info, stub_info) do
        click_button 'WIP'
      end

      assert_text '質問をWIPとして保存しました。'
      assert_no_match 'Message to Discord.', mock_log.to_s
    end

    test 'notify to chat after publish a question from WIP' do
      question = questions(:question_for_wip)
      visit_with_auth question_path(question), 'kimura'
      click_link '内容修正'

      mock_log = []
      stub_info = proc { |i| mock_log << i }

      Rails.logger.stub(:info, stub_info) do
        click_button '質問を公開'
        assert_text '質問を更新しました'
      end

      assert_match 'Message to Discord.', mock_log.to_s
    end
  end
end
