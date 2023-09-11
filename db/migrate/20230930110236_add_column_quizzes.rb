class AddColumnQuizzes < ActiveRecord::Migration[6.1]
  def up
    add_column :quizzes, :title, :string
  end

  def down
    remove_column :quizzes, :title, :string
  end
end
