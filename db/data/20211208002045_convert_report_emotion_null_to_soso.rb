# frozen_string_literal: true

class ConvertReportEmotionNullToSoso < ActiveRecord::Migration[6.1]
  def up
    Report.where(emotion: nil).update_all(emotion: Report.emotions[:soso]) # rubocop:disable Rails/SkipsModelValidations
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
