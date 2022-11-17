class CreateSurveyQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :survey_questions do |t|
      t.string :title
      t.text :description
      t.integer :format, default: 0
      t.boolean :answer_required, default: false
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
