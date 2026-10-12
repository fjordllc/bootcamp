# frozen_string_literal: true

class RenameMentorAiContextToMentoringExpertise < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :mentor_ai_context, :mentoring_expertise
  end
end
