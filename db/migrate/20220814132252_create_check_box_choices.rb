class CreateCheckBoxChoices < ActiveRecord::Migration[6.1]
  def change
    create_table :check_box_choices do |t|
      t.references :check_box, foreign_key: true
      t.string :choices
      t.boolean :reason_for_choice_required
      t.timestamps
    end
  end
end
