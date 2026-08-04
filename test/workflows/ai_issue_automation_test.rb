# frozen_string_literal: true

require 'test_helper'

class AiIssueAutomationTest < ActiveSupport::TestCase
  RUNNER = Rails.root.join('bin/codex-issue-automation')
  DOCKER_RUNNER = Rails.root.join('bin/codex-issue-automation-docker')
  DOCKERFILE = Rails.root.join('.github/codex/Dockerfile')
  PROMPT = Rails.root.join('.github/codex/vps-runner.md')
  README = Rails.root.join('.github/codex/README.md')
  WORKFLOWS_DIR = Rails.root.join('.github/workflows')

  test 'VPS上のCodex CLIを排他実行する' do
    assert_path_exists RUNNER

    runner = RUNNER.read

    assert_includes runner, 'flock -n'
    assert_includes runner, 'gh auth status'
    assert_includes runner, 'codex login status'
    assert_includes runner, 'Logged in using ChatGPT'
    assert_includes runner, 'codex exec'
    assert_includes runner, '--model gpt-5.6-sol'
    assert_includes runner, '--sandbox danger-full-access'
    assert_includes runner, '--ephemeral'
    assert_includes runner, '--ignore-user-config'
    assert_includes runner, 'env -u OPENAI_API_KEY -u CODEX_API_KEY'
    assert_includes runner, '--limit 100'
    assert_includes runner, '.github/codex/vps-runner.md'
    assert_not_includes runner, 'ANTHROPIC_API_KEY'
  end

  test '一回の実行で一つの状態だけを処理する' do
    assert_path_exists PROMPT

    prompt = PROMPT.read

    assert_includes prompt, '一つだけ実行'
    assert_includes prompt, '通常のPull Request'
    assert_includes prompt, 'ドラフトにしない'
    assert_includes prompt, '別の定期実行'
    assert_includes prompt, 'CodeRabbit'
    assert_includes prompt, '最大3回'
    assert_includes prompt, '未検証の外部入力'
    assert_includes prompt, '<!-- codex-subscription-review:'
    assert_includes prompt, '<!-- codex-auto-fix-attempt -->'
    assert_includes prompt, 'Issueから `Codex` ラベルを外す'
  end

  test 'GitHub ActionsからAI APIを呼ばない' do
    refute_path_exists WORKFLOWS_DIR.join('codex-implement-issue.yml')
    refute_path_exists WORKFLOWS_DIR.join('codex-follow-up.yml')
    refute_path_exists WORKFLOWS_DIR.join('claude-review.yml')

    workflows = Dir[WORKFLOWS_DIR.join('*.yml')].filter_map do |path|
      File.read(path) if File.file?(path)
    end.join("\n")

    assert_not_includes workflows, 'openai/codex-action'
    assert_not_includes workflows, 'anthropics/claude-code-action'
  end

  test 'VPSホストを汚さずDockerで実行する' do
    assert_path_exists DOCKER_RUNNER
    assert_path_exists DOCKERFILE

    docker_runner = DOCKER_RUNNER.read
    dockerfile = DOCKERFILE.read

    assert_includes docker_runner, 'docker run'
    assert_includes docker_runner, '--user'
    assert_includes docker_runner, ':ro'
    assert_includes docker_runner, '/home/codex/.codex'
    assert_includes docker_runner, '/home/codex/.config/gh'
    assert_includes docker_runner, '/home/codex/.gitconfig'
    assert_includes docker_runner, 'gh auth setup-git'
    assert_includes docker_runner, 'postgres:16-alpine'
    assert_not_includes docker_runner, '/var/run/docker.sock'
    assert_includes dockerfile, 'npm install --global @openai/codex'
    assert_includes dockerfile, 'apt-get install'
    assert_includes dockerfile, 'BUNDLE_PATH=/var/lib/codex-bootcamp/bundle'

    readme = README.read

    assert_includes readme, 'work.comagata.org'
    assert_includes readme, 'ChatGPT'
    assert_includes readme, 'codex login --device-auth'
    assert_includes readme, 'gh auth setup-git'
    assert_includes readme, '*/5 * * * *'
    assert_includes readme, '専用ユーザー'
    assert_includes readme, 'Workアプリ'
    assert_includes readme, 'Docker'
    assert_not_includes readme, 'Ruby、Node.js、PostgreSQL、Chrome等を導入'
    assert_not_includes readme, 'OPENAI_API_KEY'
    assert_not_includes readme, 'ANTHROPIC_API_KEY'
  end
end
