# frozen_string_literal: true

require 'application_system_test_case'

class Admin::AiPromptsTest < ApplicationSystemTestCase
  test 'non-admin cannot visit AI prompts page' do
    visit_with_auth admin_ai_prompts_path, 'kimura'

    assert_text '管理者としてログインしてください'
  end

  test 'non-admin cannot visit AI prompt edit page' do
    visit_with_auth edit_admin_ai_prompt_path('question_answer'), 'kimura'

    assert_text '管理者としてログインしてください'
  end

  test 'admin can see all manageable prompts' do
    visit_with_auth admin_ai_prompts_path, 'komagata'

    AiPrompt.definitions.each_value do |definition|
      assert_text definition.fetch(:name)
      assert_text definition.fetch(:description)
    end
    assert_selector 'a[aria-label="編集"]', count: AiPrompt.definitions.size
    assert_selector 'i[aria-hidden="true"]', count: AiPrompt.definitions.size
  end

  test 'admin can update a prompt' do
    visit_with_auth edit_admin_ai_prompt_path('question_answer'), 'komagata'
    fill_in 'ai_prompt[body]', with: '管理画面で更新したQ&Aプロンプト'
    click_button '内容を保存'

    assert_text 'AIプロンプトを更新しました。'
    assert_equal '管理画面で更新したQ&Aプロンプト', AiPrompt.find_by!(key: 'question_answer').body
  end

  test 'admin cannot save an empty prompt' do
    visit_with_auth edit_admin_ai_prompt_path('question_answer'), 'komagata'
    fill_in 'ai_prompt[body]', with: ''
    click_button '内容を保存'

    assert_text '入力内容にエラーがありました'
    assert_nil AiPrompt.find_by(key: 'question_answer')
  end
end
