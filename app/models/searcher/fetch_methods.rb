# frozen_string_literal: true

module Searcher::FetchMethods
  private

  def model(type) = search_model_name(type)&.constantize

  def extract_user_filter(words) = words.find { |w| w.match(/^user:(\w+)$/) }&.delete_prefix('user:')

  def search_by_user_filter(username, words)
    user = User.find_by(login_name: username) or return []
    filter_by_keywords(search_by_user_id(user.id), words)
  end

  def search_by_user_id(user_id)
    Searcher::AVAILABLE_TYPES.reject { |t| t == :users }.flat_map do |t|
      model(t).where(user_filter_condition(t, user_id)).to_a
    end
  end

  def user_filter_condition(type, user_id)
    type == :practices ? { last_updated_user_id: user_id } : { user_id: }
  end

  def search_users(words)
    User.where(
      words.map { |_w| 'login_name ILIKE ? OR name ILIKE ? OR description ILIKE ?' }.join(' AND '),
      *words.flat_map { |w| ["%#{w}%"] * 3 }
    )
  end

  def result_for(type, words)
    raise ArgumentError, "#{type} is not available" unless type.in?(Searcher::AVAILABLE_TYPES)
    return search_users(words) if type == :users

    klass = model(type)

    base_scope = if type == :comments
                   klass.where.not(commentable_type: 'Talk')
                 else
                   klass.all
                 end

    return base_scope if words.blank?

    apply_word_filters(base_scope, klass, words).order(updated_at: :desc)
  end

  def result_for_comments(document_type, words)
    (result_for(document_type, words).to_a + comments_for(document_type, words))
      .sort_by(&:updated_at).reverse
  end

  def result_for_questions(document_type, words)
    (result_for(document_type, words).to_a + result_for(:answers, words).to_a + result_for(:correct_answers, words).to_a)
      .sort_by(&:updated_at).reverse
  end

  def apply_word_filters(query, klass, words)
    words.reduce(query) do |q, word|
      word.start_with?('user:') ? apply_user_filter(q, klass, word) : apply_column_filter(q, klass, word)
    end
  end

  def apply_user_filter(query, klass, word)
    user = User.find_by(login_name: word.delete_prefix('user:'))
    return query.none unless user

    column =
      if klass == Practice
        :last_updated_user_id
      elsif klass.column_names.include?('user_id')
        :user_id
      end

    column ? query.where(column => user.id) : query.none
  end

  def apply_column_filter(query, klass, word)
    cols = klass.column_names & %w[title body description]
    return query if cols.empty?

    query.where(cols.map { |c| "#{c} ILIKE :word" }.join(' OR '), word: "%#{word}%")
  end

  def comments_for(document_type, words)
    all_comments = result_for(:comments, words) || []
    return all_comments if document_type == :all

    all_comments.select { |c| c.commentable_type == search_model_name(document_type) }
  end
end
