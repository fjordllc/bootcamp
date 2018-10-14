# frozen_string_literal: true

class AddTypeToAnswers < ActiveRecord::Migration[5.1]
  def change
    add_column :answers, :type, :string
  end
end
