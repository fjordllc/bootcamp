# frozen_string_literal: true

module Searcher::UserLoadingMethods
  private

  def preload_users_for(searchables)
    ids = searchables.map { |s| s.try(:user_id) }.compact.uniq
    return {} if ids.empty?

    User.where(id: ids).index_by(&:id)
  end

  def load_users_for(searchables)
    ids = searchables.map { |s| s.try(:user_id) }.compact.uniq
    return {} if ids.empty?

    User.with_attached_avatar.where(id: ids).index_by(&:id)
  end

  def load_commentable_owners_for(searchables)
    commentables_by_type = gather_commentable_ids(searchables)
    result = fetch_commentable_owner_map(commentables_by_type)
    result.merge!(fetch_question_owner_map(searchables))
    result
  end

  def gather_commentable_ids(searchables)
    commentables_by_type = Hash.new { |h, k| h[k] = [] }
    searchables.each do |s|
      next unless s.is_a?(Comment)

      commentables_by_type[s.commentable_type] << s.commentable_id
    end
    commentables_by_type
  end

  def fetch_commentable_owner_map(commentables_by_type)
    result = {}
    commentables_by_type.each do |type_name, ids|
      klass = type_name.safe_constantize
      next unless klass&.column_names&.include?('user_id')

      klass.where(id: ids.uniq).pluck(:id, :user_id).each do |id, uid|
        result[:"#{type_name}_#{id}"] = uid
      end
    end
    result
  end

  def fetch_question_owner_map(searchables)
    result = {}
    question_ids = searchables.select { |s| s.is_a?(Answer) || s.is_a?(CorrectAnswer) }
                              .map { |a| a.try(:question_id) }.compact.uniq
    return result if question_ids.empty?

    Question.where(id: question_ids).pluck(:id, :user_id).each do |id, uid|
      result[:"Question_#{id}"] = uid
    end
    result
  end
end
