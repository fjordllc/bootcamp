class CreateRadioButtonChoices < ActiveRecord::Migration[6.1]
  def change
    create_table :radio_button_choices do |t|
      t.references :radio_button, foreign_key: true
      t.string :choices
      t.boolean :reason_for_choice_required
      t.timestamps
    end
  end
end
