# frozen_string_literal: true

class AddEmptyStringToNilDescription < ActiveRecord::Migration[6.1]
  def up
    now = Time.current

    User.where(description: nil).update_all(description: '自己紹介文はありません。', updated_at: now)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
