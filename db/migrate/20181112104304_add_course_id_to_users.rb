# frozen_string_literal: true

class AddCourseIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :course
  end
end
