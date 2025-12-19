# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/mock_helper'

module Questions
  class PaginationTest < ApplicationSystemTestCase
    include MockHelper

    setup do
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
      mock_openai_chat_completion(content: 'Test AI response')
    end

    test 'Question display 25 items correctly' do
      # 既存の解決済み質問数を確認し、26件になるよう必要な数だけ作成
      existing_count = Question.solved.count
      needed = [26 - existing_count, 0].max
      user = users(:hajime)
      practice = practices(:practice1)

      needed.times do |n|
        q = Question.create(title: "ページネーションテスト#{n}", description: "答え#{n}", user:, practice:)
        Answer.create(description: '正しい答え', user:, question_id: q.id, type: 'CorrectAnswer')
      end

      visit_with_auth questions_path(target: 'solved'), 'kimura'

      assert_selector '.card-list-item', count: 25
      first('.pagination__item-link', text: '2').click
      assert_selector '.card-list-item', count: 1
    end

    test "visit user profile page when clicked on user's name on question" do
      visit_with_auth questions_path(target: 'not_solved'), 'kimura'
      assert_text '質問のタブの作り方'
      click_link 'hatsuno (Hatsuno Shinji)', match: :first
      assert_text 'プロフィール'
      assert_text 'Hatsuno Shinji（ハツノ シンジ）'
    end

    test 'show number of unanswered questions' do
      visit_with_auth questions_path(practice_id: practices(:practice1).id, target: 'not_solved'), 'komagata'
      assert_selector '.not-solved-count', text: Question.not_solved.not_wip.where(practice_id: practices(:practice1).id).size
    end
  end
end
