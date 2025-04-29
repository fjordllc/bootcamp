# frozen_string_literal: true

class Admin::CourseDiffsController < AdminController
  def index
    @rails_course = rails_course.index_by do |item|
      item['practice_id'].to_i
    end
    @rails_reskill_course = rails_reskill_course do |item|
      item['practice_id'].to_i
    end
  end

  def show; end

  private

  def rails_course
    ActiveRecord::Base.connection.select_all(<<~SQL.squish)
      SELECT
        categories.id AS category_id,
        categories.name AS category_name,
        practices.id AS practice_id,
        practices.title AS practice_title,
        practices2.id AS practice2_id,
        practices2.title AS practice2_title
      FROM
        courses
        JOIN courses_categories ON courses.id = courses_categories.course_id
        JOIN categories ON courses_categories.category_id = categories.id
        JOIN categories_practices ON categories.id = categories_practices.category_id
        JOIN practices ON categories_practices.practice_id = practices.id
        LEFT JOIN practices AS practices2 ON practices.id = practices2.source_id
        LEFT JOIN submission_answers ON practices.id = submission_answers.practice_id
      WHERE
        courses.title = 'Railsエンジニア'
      ORDER BY
        courses_categories.position,
        categories_practices.position
    SQL
  end

  def rails_reskill_course
    ActiveRecord::Base.connection.select_all(<<~SQL.squish)
      SELECT
        categories.id AS category_id,
        categories.name AS category_name,
        practices.id AS practice_id,
        practices.title AS practice_title,
        practices.submission,
        submission_answers.description
      FROM
        courses
        JOIN courses_categories ON courses.id = courses_categories.course_id
        JOIN categories ON courses_categories.category_id = categories.id
        JOIN categories_practices ON categories.id = categories_practices.category_id
        JOIN practices ON categories_practices.practice_id = practices.id
        LEFT JOIN submission_answers ON practices.id = submission_answers.practice_id
      WHERE
        courses.title = '（Reスキル講座認定）'
      ORDER BY
        courses_categories.position,
        categories_practices.position
    SQL
  end
end
