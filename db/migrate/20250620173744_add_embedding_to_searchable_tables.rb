class AddEmbeddingToSearchableTables < ActiveRecord::Migration[6.1]
  def up
    add_column :practices, :embedding, :vector, limit: 768
    add_column :reports, :embedding, :vector, limit: 768
    add_column :products, :embedding, :vector, limit: 768
    add_column :pages, :embedding, :vector, limit: 768
    add_column :questions, :embedding, :vector, limit: 768
    add_column :announcements, :embedding, :vector, limit: 768
    add_column :events, :embedding, :vector, limit: 768
    add_column :regular_events, :embedding, :vector, limit: 768
    add_column :answers, :embedding, :vector, limit: 768
    add_column :faqs, :embedding, :vector
    add_column :submission_answers, :embedding, :vector, limit: 768
  end

  def down
    remove_column :practices, :embedding
    remove_column :reports, :embedding
    remove_column :products, :embedding
    remove_column :pages, :embedding
    remove_column :questions, :embedding
    remove_column :announcements, :embedding
    remove_column :events, :embedding
    remove_column :regular_events, :embedding
    remove_column :answers, :embedding
    remove_column :faqs, :embedding
    remove_column :submission_answers, :embedding
  end
end
