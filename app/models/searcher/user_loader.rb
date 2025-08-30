# frozen_string_literal: true

class Searcher::UserLoader
  def initialize(searchables)
    @searchables = Array(searchables)
  end

  def load
    ids = @searchables.map { |s| s.try(:user_id) }.compact.uniq
    return {} if ids.empty?

    User.where(id: ids).index_by(&:id)
  end

  def load_with_avatar
    ids = @searchables.map { |s| s.try(:user_id) }.compact.uniq
    return {} if ids.empty?

    User.with_attached_avatar.where(id: ids).index_by(&:id)
  end
end
