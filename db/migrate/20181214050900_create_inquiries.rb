# frozen_string_literal: true

class CreateInquiries < ActiveRecord::Migration[5.2]
  def change
    create_table :inquiries do |t|
      t.string :name
      t.string :email
      t.text :body

      t.timestamps
    end
  end
end
