# frozen_string_literal: true

module UserAssociations3
  extend ActiveSupport::Concern

  included do
    has_many :participate_events,
             through: :participations,
             source: :event

    has_many :send_notifications,
             class_name: 'Notification',
             foreign_key: 'sender_id',
             inverse_of: 'sender',
             dependent: :destroy

    has_many :completed_learnings,
             -> { where(status: 'complete') },
             class_name: 'Learning',
             inverse_of: 'user',
             dependent: :destroy

    has_many :completed_practices,
             through: :completed_learnings,
             source: :practice,
             dependent: :destroy

    has_many :active_learnings,
             -> { where(status: 'started') },
             class_name: 'Learning',
             inverse_of: 'user',
             dependent: :destroy
  end
end
