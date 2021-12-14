# frozen_string_literal: true

class ChangeKomagata < ActiveRecord::Migration[6.0]
  def up
    user = User.find_by(login_name: 'komagata')
    user.update!(name: "#{user.name}test")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
