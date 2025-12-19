# frozen_string_literal: true

class FixMultipleCorrectAnswers < ActiveRecord::Migration[6.1]
  def up
    # ベストアンサーが複数あれば最新のもの以外を通常の回答に降格する
    duplicates = CorrectAnswer.group(:question_id).having('COUNT(*) > 1').pluck(:question_id)
    duplicates.each do |question_id|
      answers = CorrectAnswer.where(question_id:).order(created_at: :desc).offset(1)
      answers.update_all(type: nil)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
