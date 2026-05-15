# frozen_string_literal: true

class ChangeCategoriesCoursesForCoursesCategoryModel < ActiveRecord::Migration[6.1]
  def up
    rename_table :categories_courses, :courses_categories

    change_table :courses_categories, bulk: true do |t|
      t.primary_key :id
      t.integer :position
      t.datetime :created_at
      t.datetime :updated_at
      t.index %i[course_id category_id], unique: true
    end

    ActiveRecord::Base.connection.execute(<<~SQL)
      UPDATE
        courses_categories AS dst
      SET
        position = src.position,
        created_at = now(),
        updated_at = now()
      FROM (
        SELECT
          cc.course_id AS course_id,
          cc.category_id AS category_id,
          row_number() OVER(PARTITION BY cc.course_id ORDER BY c.position) AS position
        FROM
          courses_categories AS cc
          INNER JOIN categories AS c ON c.id = cc.category_id
        ORDER BY cc.course_id, c.position
      ) AS src
      WHERE
        dst.course_id = src.course_id AND dst.category_id = src.category_id
      ;
    SQL

    change_table :courses_categories, bulk: true do |t|
      t.change_null :position, false
      t.change_null :created_at, false
      t.change_null :updated_at, false
    end
  end

  def down
    change_table :courses_categories, bulk: true do |t|
      t.remove_index %i[course_id category_id]
      t.remove :updated_at
      t.remove :created_at
      t.remove :position
      t.remove :id, primary_key: true
    end

    rename_table :courses_categories, :categories_courses
  end
end
