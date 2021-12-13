# frozen_string_literal: true

class ConvertReportEmotionNullToSoso < ActiveRecord::Migration[6.1]
  def up
    Report.where(emotion: nil).find_each do |report|
      report.update!(emotion: Report.emotions[:soso])
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
