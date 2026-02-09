# frozen_string_literal: true

module QuestionAutoCloserHelper
  def create_question(wip: false)
    created_at = Time.zone.local(2025, 10, 1, 0, 0, 0)
    Question.create!(
      title: '自動クローズテスト',
      description: 'テスト',
      user: users(:kimura),
      wip:,
      created_at:,
      updated_at: created_at
    )
  end
end
