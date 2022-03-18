# frozen_string_literal: true

class CopyTimestampCreatedAtToPublishedAtForQuestions < ActiveRecord::Migration[6.1]
  def up
    Question.where(wip: false).where(published_at: nil).find_each do |question|
      question.published_at = question.created_at
      question.save!(validate: false)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
