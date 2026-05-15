class AddWipAndPublishedAtToQuestions < ActiveRecord::Migration[6.1]
  def change
    add_column :questions, :wip, :boolean, null: false, default: false
    add_column :questions, :published_at, :datetime
  end
end
