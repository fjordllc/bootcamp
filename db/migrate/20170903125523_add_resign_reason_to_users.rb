class AddResignReasonToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :resign_reason, :text
  end
end
