class CreateLinearScales < ActiveRecord::Migration[6.1]
  def change
    create_table :linear_scales do |t|
      t.string :start_of_scale
      t.string :end_of_scale
      t.boolean :reason_for_choice_required, default: false
      t.string :title_of_reason
      t.text :description_of_reason
      t.references :survey_question, foreign_key: true
      t.timestamps
    end
  end
end
