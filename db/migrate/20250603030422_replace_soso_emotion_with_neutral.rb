class ReplaceSosoEmotionWithNeutral < ActiveRecord::Migration[6.1]
  def up
    Report.where(emotion: 0).update_all(emotion: Report.emotions[:neutral])
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
