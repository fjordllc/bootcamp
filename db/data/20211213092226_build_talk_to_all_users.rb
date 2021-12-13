class BuildTalkToAllUsers < ActiveRecord::Migration[6.1]
  def up
    User.all.each do |user|
      user.build_talk.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
