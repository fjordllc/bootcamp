class ConvertBookToPracticesBook < ActiveRecord::Migration[6.1]
  def up
    Book.all.each do |book|
      PracticesBook.new(
        practice_id: book.practice_id,
        book_id: book.id,
        must_read: book.must_read,
        created_at: book.created_at,
        updated_at: book.updated_at
      ).save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
