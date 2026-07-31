# frozen_string_literal: true

module UserAssociations6
  extend ActiveSupport::Concern

  included do
    has_many :oauth_access_grants,
             foreign_key: 'resource_owner_id',
             dependent: :delete_all,
             inverse_of: 'user'

    has_many :oauth_access_tokens,
             foreign_key: 'resource_owner_id',
             dependent: :delete_all,
             inverse_of: 'user'

    has_one_attached :avatar
    has_one_attached :profile_image
    has_one_attached :diploma_file
  end
end
