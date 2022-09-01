class CreateSurveyQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :survey_questions do |t|
      t.string :question_title
      t.text :question_description
      t.integer :question_format, default: 0
      t.boolean :answer_required, default: false
      t.references :creator, foreign_key: { to_table: :users }
      t.references :updater, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
