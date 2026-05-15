# frozen_string_literal: true

class UpdateCompletionMessageDisplayedToLearnings < ActiveRecord::Migration[6.1]
  def up
    Learning.complete.update_all(completion_message_displayed: true) # rubocop:disable Rails/SkipsModelValidations
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
