# frozen_string_literal: true

class MigrateActionCompletionDetailsToInquiriesFromChecks < ActiveRecord::Migration[7.2]
  def up
    # 対応情報が誤って重複登録され得るバグがあった
    # 稀ではあるが重複がある場合`find_each`の仕様上idの古い順に処理し、最後に最も新しいもので上書きする
    checks = Check.where(checkable_type: 'Inquiry')
    checks.find_each do |check|
      inquiry = Inquiry.find_by(id: check.checkable_id)
      next unless inquiry

      inquiry.update!(action_completed: true, completed_by_user_id: check.user_id, completed_at: check.created_at)
    end

    checks.delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
