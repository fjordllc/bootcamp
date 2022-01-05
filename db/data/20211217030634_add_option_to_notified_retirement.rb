# frozen_string_literal: true

class AddOptionToNotifiedRetirement < ActiveRecord::Migration[6.1]
  def up
    User.retired.find_each do |retired_user|
      retired_user.update!(notified_retirement: true) if retired_user.retired_on <= Date.current - 3.months
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
