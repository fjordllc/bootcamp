# frozen_string_literal: true

class PjordChatSession < ApplicationRecord
  belongs_to :user
  has_many :messages, class_name: 'PjordChatMessage', dependent: :destroy
end
