# frozen_string_literal: true

class Textbook::Chapter < ApplicationRecord
  self.table_name = 'textbook_chapters'

  belongs_to :textbook
  has_many :sections, class_name: 'Textbook::Section', foreign_key: 'textbook_chapter_id', dependent: :destroy, inverse_of: :chapter

  validates :title, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 },
                       uniqueness: { scope: :textbook_id }

  default_scope { order(:position) }
end
