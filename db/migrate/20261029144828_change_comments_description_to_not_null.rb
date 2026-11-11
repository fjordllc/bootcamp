class ChangeCommentsDescriptionToNotNull < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      ALTER TABLE comments
      ADD CONSTRAINT comments_description_to_not_null
      CHECK(description IS NOT NULL) NOT VALID;
    SQL

    execute <<~SQL
      ALTER TABLE comments
      VALIDATE CONSTRAINT comments_description_to_not_null;
    SQL

    change_column_null :comments, :description, false

    execute <<~SQL
      ALTER TABLE comments
      DROP CONSTRAINT comments_description_to_not_null;
    SQL
  end

    def down
      change_column_null :comments, :description, true
    end

end
