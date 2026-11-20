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
    @grouped_reactions ||= reaction_rows.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |array, hash|
      id, kind, login_name = array
      hash[kind] << { id:, login_name: }
    end.with_indifferent_access
  end

  # reactionsが読み込み済みなら、一覧でレコードごとにSQLを発行しないよう、読み込み済みのリアクションから求める。
  def reaction_rows
    if reactions.loaded?
      reactions.select(&:user).sort_by(&:created_at).map { |reaction| [reaction.id, reaction.kind, reaction.user.login_name] }
    else
      reactions.joins(:user).order(created_at: :asc).pluck(:id, :kind, :'users.login_name')
    end
  end
end
