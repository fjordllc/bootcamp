# frozen_string_literal: true

class Textbook::Section < ApplicationRecord
  self.table_name = 'textbook_sections'

  belongs_to :chapter, class_name: 'Textbook::Chapter', foreign_key: 'textbook_chapter_id', inverse_of: :sections
  has_many :reading_progresses, foreign_key: 'textbook_section_id', dependent: :destroy, inverse_of: :section
  has_many :term_explanations, foreign_key: 'textbook_section_id', dependent: :destroy, inverse_of: :section

  validates :title, presence: true
  validates :body, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Sections must always be ordered by position for consistent display in chapters.
  default_scope { order(:position) }
end
