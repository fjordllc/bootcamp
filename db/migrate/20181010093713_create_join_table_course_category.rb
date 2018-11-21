# frozen_string_literal: true

class CreateJoinTableCourseCategory < ActiveRecord::Migration[5.2]
  def change
    create_join_table :courses, :categories do |t|
      # t.index [:course_id, :category_id]
      # t.index [:category_id, :course_id]
    end
  end
end
