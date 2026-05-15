# frozen_string_literal: true

module Bookmarkable
  extend ActiveSupport::Concern

  included do
    has_many :bookmarks, as: :bookmarkable, dependent: :destroy
  end
end
