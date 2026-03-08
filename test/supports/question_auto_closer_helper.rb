# frozen_string_literal: true

module QuestionAutoCloserHelper
  def create_question(wip: false)
    # 再現性のために時刻を固定。値は任意
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
