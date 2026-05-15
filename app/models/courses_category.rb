# frozen_string_literal: true

class CoursesCategory < ApplicationRecord
  default_scope -> { order(:position) }
  belongs_to :course
  belongs_to :category
  acts_as_list scope: :course
end
