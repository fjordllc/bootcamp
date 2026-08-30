# frozen_string_literal: true

# Practiceのdelegate宣言からのみ使う、非公開の委譲先オブジェクトをまとめたもの。
# ここに定義されたメソッドは全てprivateであり、Practiceの公開APIではない。
module PracticeDelegateTargets
  extend ActiveSupport::Concern

  private

  def study_minutes
    PracticeStudyMinutes.new(self)
  end
end
