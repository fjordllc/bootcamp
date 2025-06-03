# frozen_string_literal: true

class ConvertReportEmotionNullToNeutral < ActiveRecord::Migration[6.1]
  def up
    Report.where(emotion: nil).update_all(emotion: Report.emotions[:neutral]) # rubocop:disable Rails/SkipsModelValidations
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
