# frozen_string_literal: true

class MigratePrefectureDataToCountryAndSubdivision < ActiveRecord::Migration[6.1]
  def up
    User.where.not(prefecture_code: nil).find_each do |user|
      user.country_code = 'JP'
      user.subdivision_code = user.prefecture_code.to_s.rjust(2, '0')
      user.save(validate: false)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
