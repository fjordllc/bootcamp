# frozen_string_literal: true

require 'browserless_system_test_case'

class Admin::AiPromptsBrowserlessTest < BrowserlessSystemTestCase
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
end
