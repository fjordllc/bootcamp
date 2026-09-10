# frozen_string_literal: true

class CopyMentorMemoToMentorMemos < ActiveRecord::Migration[8.1]
  def up
    User.find_each do |user|
      next if user.mentor_memo.blank?

      mentor_memo = user.mentor_memos.build(content: user.mentor_memo)
      mentor_memo.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
