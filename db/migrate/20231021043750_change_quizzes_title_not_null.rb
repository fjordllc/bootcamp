class ChangeQuizzesTitleNotNull < ActiveRecord::Migration[6.1]
  def change
    change_column_null :quizzes, :title, false
  end
end
