class AddEmptyStringToNilDescription < ActiveRecord::Migration[6.1]
  def up
    User.find_each do |user|
      if user.description.nil?
        user.description = "*自己紹介文はありません*"
        user.save!
      end
    end
  end

  def down
    puts "down"
  end
end
