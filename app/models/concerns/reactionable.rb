# frozen_string_literal: true

module Reactionable
  extend ActiveSupport::Concern

  included do
    has_many :reactions, as: :reactionable, dependent: :delete_all
  end

  def find_reaction_id_by(kind, login_name)
    grouped_reactions[kind].find { |h| h[:login_name] == login_name }&.fetch(:id)
  end

  def reaction_count_by(kind)
    grouped_reactions[kind].length
  end

  def reaction_login_names_by(kind)
    grouped_reactions[kind].map { |h| h[:login_name] }
  end

  private

    def grouped_reactions
      @_grouped_reactions ||= reactions.joins(:user).order(created_at: :asc).pluck(:id, :kind, :"users.login_name").each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |array, hash|
        id, kind, login_name = array
        hash[kind] << { id: id, login_name: login_name }
      end.with_indifferent_access
    end
end
