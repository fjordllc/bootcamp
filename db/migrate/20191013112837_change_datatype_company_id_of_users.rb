# frozen_string_literal: true

class ChangeDatatypeCompanyIdOfUsers < ActiveRecord::Migration[5.2]
  def up
    change_column_null :users, :company_id, true
    change_column_default :users, :company_id, from: 1, to: nil
  end

  def down
    User.where(company_id: nil).update_all(company_id: 1) # rubocop:disable Rails/SkipsModelValidations
    change_column_default :users, :company_id, from: nil, to: 1
    change_column_null :users, :company_id, false
  end
end
