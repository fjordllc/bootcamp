# frozen_string_literal: true

class ReadingProgress < ApplicationRecord
  belongs_to :user
  belongs_to :section, class_name: 'Textbook::Section', foreign_key: 'textbook_section_id', inverse_of: :reading_progresses

  validates :read_ratio, presence: true, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0 }
  validates :user_id, uniqueness: { scope: :textbook_section_id }

  def complete!
    update!(completed: true, read_ratio: 1.0, last_read_at: Time.current)
  end
end
