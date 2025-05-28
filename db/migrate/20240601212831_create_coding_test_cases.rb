class CreateCodingTestCases < ActiveRecord::Migration[6.1]
  def change
    create_table :coding_test_cases do |t|
      t.text :input
      t.text :output
      t.references :coding_test, null: false, foreign_key: true

      t.timestamps
    end
  end
end
