# frozen_string_literal: true

require 'test_helper'

class AiPromptTest < ActiveSupport::TestCase
  test '.definitions returns seven manageable prompts' do
    assert_equal %w[
      article_meta_description
      pjord
      mention_response
      product_review
      question_answer
      report_classifier
      report_comment
    ], AiPrompt.definitions.keys
  end

  test '.body_for returns the default prompt when not saved' do
    assert_includes AiPrompt.body_for('article_meta_description'), 'SEO分析の専門家'
  end

  test '.body_for returns the saved prompt immediately' do
    AiPrompt.create!(key: 'article_meta_description', body: '管理画面で変更したプロンプト')

    assert_equal '管理画面で変更したプロンプト', AiPrompt.body_for('article_meta_description')
  end

  test 'validates key and body' do
    prompt = AiPrompt.new(key: 'unknown', body: '')

    assert_not prompt.valid?
    assert prompt.errors.added?(:key, :inclusion, value: 'unknown')
    assert prompt.errors.added?(:body, :blank)
  end

  test 'validates key uniqueness' do
    AiPrompt.create!(key: 'pjord', body: '共通プロンプト')
    duplicate = AiPrompt.new(key: 'pjord', body: '別の共通プロンプト')

    assert_not duplicate.valid?
    assert duplicate.errors.added?(:key, :taken, value: 'pjord')
  end

  test 'does not evaluate saved ERB' do
    body = '<%= raise "executed" %>'
    AiPrompt.create!(key: 'pjord', body:)

    assert_equal body, AiPrompt.body_for('pjord')
  end
end
