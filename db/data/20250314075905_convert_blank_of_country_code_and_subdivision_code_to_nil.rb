# frozen_string_literal: true

class ConvertBlankOfCountryCodeAndSubdivisionCodeToNil < ActiveRecord::Migration[6.1]
  def up
    User.find_each do |user|
      if user.country_code.blank?
        user.country_code = nil
        user.subdivision_code = nil
      elsif user.subdivision_code.blank?
        user.subdivision_code = nil
      end
      user.save!(validate: false)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
