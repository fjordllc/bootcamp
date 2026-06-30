# frozen_string_literal: true

class CopyUserMentorMemoColumnToMentorMemos < ActiveRecord::Migration[8.1]
  def up
    pjord = User.find_by!(login_name: "pjord")
    User.where.not(mentor_memo: [nil, ""] ).find_each do |user|
      MentorMemo.create!(recipient: user, writer: pjord, body: "【2026年6月以前のメモ】\n#{user.mentor_memo}")
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
