class AddPositionToFAQ < ActiveRecord::Migration[6.1]
  def change
    add_column :faqs, :position, :integer
  end
end
