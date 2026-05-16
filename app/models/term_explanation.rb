# frozen_string_literal: true

class TermExplanation < ApplicationRecord
  belongs_to :section, class_name: 'Textbook::Section', foreign_key: 'textbook_section_id', inverse_of: :term_explanations

  validates :term, presence: true, uniqueness: { scope: :textbook_section_id }
  validates :explanation, presence: true
end
