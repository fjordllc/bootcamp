# frozen_string_literal: true

class CopyMentorMemoToMentorMemos < ActiveRecord::Migration[8.1]
  def up
    User.where.not(mentor_memo: [nil, '']).find_each do |user|
      mentor_memo = user.mentor_memos.build(content: user.mentor_memo)
      mentor_memo.record_timestamps = false
      mentor_memo.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
