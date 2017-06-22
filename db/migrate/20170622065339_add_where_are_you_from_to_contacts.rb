class AddWhereAreYouFromToContacts < ActiveRecord::Migration[5.0]
  def change
    add_column :contacts, :where_are_you_from, :string
  end
end
