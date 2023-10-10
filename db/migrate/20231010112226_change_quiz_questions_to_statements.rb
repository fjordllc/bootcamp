class ChangeQuizQuestionsToStatements < ActiveRecord::Migration[6.1]
  def change
    rename_table :quiz_questions, :statements
  end
end
