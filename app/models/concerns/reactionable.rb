# frozen_string_literal: true

module Reactionable
  extend ActiveSupport::Concern

  included do
    has_many :reactions, as: :reactionable, dependent: :delete_all
  end

  def reacted_id(user, kind)
    @_reacted_ids ||= Hash[*reactions.where(user: user).pluck(:kind, :id).flatten]
    @_reacted_ids[kind]
  end

  def reacted_count(kind)
    @_reacted_counts ||= reactions.pluck(:kind).each_with_object(Hash.new(0)) do |kind, hash|
      hash[kind] += 1
    end
    @_reacted_counts[kind]
  end
end
