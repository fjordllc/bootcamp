# frozen_string_literal: true

module Watchable
  extend ActiveSupport::Concern

  included do
    has_many :watches, as: :watchable, dependent: :delete_all

    scope :watched, -> { joins(:watches) }
  end

end
