# frozen_string_literal: true

class AddOptionToNotifiedRetirement < ActiveRecord::Migration[6.1]
  def up
    User.retired.find_each do |retired_user|
      if retired_user.retired_on <= Date.current - 3.months
        retired_user.notified_retirement = true
        retired_user.save!(validate: false)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
