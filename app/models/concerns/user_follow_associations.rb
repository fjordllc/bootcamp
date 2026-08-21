# frozen_string_literal: true

module UserFollowAssociations
  extend ActiveSupport::Concern

  included do
    has_many :active_relationships,
             class_name: 'Following',
             foreign_key: 'follower_id',
             inverse_of: 'follower',
             dependent: :destroy

    has_many :followees,
             through: :active_relationships,
             source: :followed

    has_many :passive_relationships,
             class_name: 'Following',
             foreign_key: 'followed_id',
             inverse_of: 'followed',
             dependent: :destroy

    has_many :followers,
             through: :passive_relationships,
             source: :follower

    has_many :send_notifications,
             class_name: 'Notification',
             foreign_key: 'sender_id',
             inverse_of: 'sender',
             dependent: :destroy
  end
end
