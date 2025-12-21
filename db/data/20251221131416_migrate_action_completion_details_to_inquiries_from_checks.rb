# frozen_string_literal: true

class MigrateActionCompletionDetailsToInquiriesFromChecks < ActiveRecord::Migration[7.2]
  def up
    Check.where(checkable_type: 'Inquiry').find_each do |check|
      inquiry = Inquiry.find(check.checkable_id)
      inquiry.update!(action_completed: true, completed_by_user_id: check.user_id, completed_at: check.created_at)
    end

    Check.where(checkable_type: 'Inquiry').destroy_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
