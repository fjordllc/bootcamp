# frozen_string_literal: true

class RenameMentorProfileToMentorAiContext < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :mentor_profile, :mentor_ai_context
  end
end
