class SorceryActivityLogging < ActiveRecord::Migration[6.1]
  class User < ActiveRecord::Base; end

  def change
    add_column :users, :last_activity_at,  :datetime

    User.reset_column_information
    User.find_each do |user|
      user.update_columns(last_activity_at: user.updated_at)
    end
  end
end
