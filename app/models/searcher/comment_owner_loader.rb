# frozen_string_literal: true

class Searcher::CommentOwnerLoader
  def initialize(searchables)
    @searchables = Array(searchables)
  end

  def load
    commentables_by_type = gather_commentable_ids
    result = fetch_commentable_owner_map(commentables_by_type)
    result.merge!(fetch_question_owner_map)
  end

  private

  def gather_commentable_ids
    commentables = Hash.new { |hash, key| hash[key] = [] }
    @searchables.each do |s|
      next unless s.is_a?(Comment)

      commentables[s.commentable_type] << s.commentable_id
    end
    commentables
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

  def fetch_question_owner_map
    result = {}
    question_ids = @searchables.select { |s| s.is_a?(Answer) || s.is_a?(CorrectAnswer) }
                               .map(&:question_id).compact.uniq
    return result if question_ids.empty?

    Question.where(id: question_ids).pluck(:id, :user_id).each do |id, uid|
      result[:"Question_#{id}"] = uid
    end
    result
  end
end
