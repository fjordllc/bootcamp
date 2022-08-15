class CreateRadioButtons < ActiveRecord::Migration[6.1]
  def change
    create_table :radio_buttons do |t|
      t.string :title_of_reason_for_choice
      t.text :description_of_reason_for_choice
      t.references :survey_question, foreign_key: true
      t.timestamps
    end
  end
end
