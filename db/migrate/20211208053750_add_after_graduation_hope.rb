class AddAfterGraduationHope < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :after_graduation_hope, :text
  end
end
