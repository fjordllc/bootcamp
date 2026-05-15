# frozen_string_literal: true

class PiyoChatMessage < ApplicationRecord
  belongs_to :user
  belongs_to :section, class_name: 'Textbook::Section', foreign_key: 'textbook_section_id', inverse_of: :piyo_chat_messages

  validates :role, presence: true, inclusion: { in: %w[user assistant] }
  validates :content, presence: true

  scope :recent, -> { order(created_at: :asc) }
end
