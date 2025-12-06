# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/mock_helper'

class QuestionsTest < ApplicationSystemTestCase
  include MockHelper

  setup do
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
    mock_openai_chat_completion(content: 'Test AI response')
  end

  test 'show a resolved question' do
    question = questions(:question3)
    visit_with_auth question_path(question), 'kimura'
    assert_text '解決済'
  end

  test 'notify to chat after publish a question' do
    visit_with_auth new_question_path, 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'タイトル'
      fill_in 'question[description]', with: '本文'
    end
    mock_log = []
    stub_info = proc { |i| mock_log << i }

    Rails.logger.stub(:info, stub_info) do
      click_button '登録する'
    end

    assert_text '質問を作成しました。'
    assert_match 'Message to Discord.', mock_log.to_s
  end

  test 'using file uploading by file selection dialogue in textarea' do
    visit_with_auth new_question_path, 'kimura'
    within(:css, '.a-file-insert') do
      assert_selector 'input.file-input', visible: false
    end
    assert_equal '.file-input', find('textarea.a-text-input')['data-input']
  end
end
