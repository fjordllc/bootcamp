# frozen_string_literal: true

class AddPracticeIdToPages < ActiveRecord::Migration[6.0]
  def change
    add_reference :pages, :practice, foreign_key: true
  end
end
