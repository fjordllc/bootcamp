# frozen_string_literal: true

require 'test_helper'

class Admin::AiPromptsAuthorizationTest < ActionDispatch::IntegrationTest
  test 'non-admin cannot update an AI prompt directly' do
    patch admin_ai_prompt_path('question_answer', _login_name: 'kimura'),
          params: { ai_prompt: { body: '管理者以外が更新したプロンプト' } }

    assert_redirected_to root_path
    assert_nil AiPrompt.find_by(key: 'question_answer')
  end
end
