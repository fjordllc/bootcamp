# frozen_string_literal: true

class PjordChatMessage < ApplicationRecord
  ROLES = %w[user assistant].freeze

  belongs_to :session, class_name: 'PjordChatSession', foreign_key: :pjord_chat_session_id, inverse_of: :messages

  validates :role, presence: true, inclusion: { in: ROLES }
  validates :body, presence: true, length: { maximum: 20_000 }
end
