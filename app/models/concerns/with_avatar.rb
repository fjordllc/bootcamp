# frozen_string_literal: true

module WithAvatar
  extend ActiveSupport::Concern

  included do
    scope :with_avatar, -> { preload(user: { avatar_attachment: :blob }) }
  end
end
