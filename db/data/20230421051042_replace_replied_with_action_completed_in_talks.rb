# frozen_string_literal: true

class ReplaceRepliedWithActionCompletedInTalks < ActiveRecord::Migration[6.1]
  def up
    Talk.find_each do |talk|
      talk.update!(action_completed: !talk.unreplied)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
