# frozen_string_literal: true

# Practiceのdelegate宣言からのみ使う、非公開の委譲先オブジェクトをまとめたもの。
# ここに定義されたメソッドは全てprivateであり、Practiceの公開APIではない。
module PracticeDelegateTargets
  extend ActiveSupport::Concern

  private

  def study_minutes
    PracticeStudyMinutes.new(self)
  end

  def text
    PracticeText.new(self)
  end

  def must_read_books
    PracticeMustReadBooks.new(self)
  end
end
