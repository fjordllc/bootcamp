# frozen_string_literal: true

class ChangeDatatypeCompanyIdOfUsers < ActiveRecord::Migration[5.2]
  def change
    change_column_null :users, :company_id, true
    change_column_default :users, :company_id, nil
  end
end
