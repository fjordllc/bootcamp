# frozen_string_literal: true

require 'test_helper'

class AiIssueAutomationTest < ActiveSupport::TestCase
  WORKFLOWS_DIR = Rails.root.join('.github/workflows')

  test 'AIラベルを付けたissueをGPT-5.6 SOLで実装する' do
    workflow = workflow_source('codex-implement-issue.yml')

    assert_includes workflow, 'types: [labeled]'
    assert_includes workflow, "github.event.label.name == 'AI'"
    assert_includes workflow, 'uses: openai/codex-action@v1'
    assert_includes workflow, 'model: gpt-5.6-sol'
    assert_includes workflow, '--draft=false'
  end

  test 'ClaudeはCodexが作ったPRのレビューだけを行う' do
    workflow = workflow_source('claude-review.yml')

    assert_includes workflow, 'uses: anthropics/claude-code-action@v1'
    assert_includes workflow, 'ai/issue-'
    assert_includes workflow, 'コードを変更しない'
    refute_path_exists WORKFLOWS_DIR.join('claude.yml')
  end

  test 'CIとAIレビューを5分ごとに確認して修正回数を制限する' do
    workflow = workflow_source('codex-follow-up.yml')

    assert_includes workflow, 'cron: "*/5 * * * *"'
    assert_includes workflow, 'MAX_FIX_ATTEMPTS: "3"'
    assert_includes workflow, 'coderabbitai'
    assert_includes workflow, 'claude'
    assert_includes workflow, 'model: gpt-5.6-sol'
  end

  private

  def workflow_source(name)
    WORKFLOWS_DIR.join(name).read
  end
end
