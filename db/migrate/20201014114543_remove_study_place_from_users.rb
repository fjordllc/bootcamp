# frozen_string_literal: true

class RemoveStudyPlaceFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :study_place, :integer
  end
end
