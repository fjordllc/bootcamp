# frozen_string_literal: true

class Searcher
  include SearchHelper

  DOCUMENT_TYPES = [
    ['すべて', :all],
    ['お知らせ', :announcements],
    ['プラクティス', :practices],
    ['日報', :reports],
    ['提出物', :products],
    ['Q&A', :questions],
    ['Docs', :pages],
    ['イベント', :events],
    ['定期イベント', :regular_events],
    ['ユーザー', :users]
  ].freeze

  AVAILABLE_TYPES = DOCUMENT_TYPES.map(&:second) - %i[all] + %i[comments answers]

  def self.fetch_url(searchable)
      searchable_url(searchable)
  rescue NoMethodError
      nil
  end

  def self.search(word, current_user:, document_type: :all)
    words = word.split(/[[:blank:]]+/).reject(&:blank?)
    searchables = case document_type
                  when :all
                    result_for_all(words)
                  when commentable?(document_type)
                    result_for_comments(document_type, words)
                  when :questions
                    result_for_questions(document_type, words)
                  else
                    result_for(document_type, words).sort_by(&:updated_at).reverse
                  end

    searchables = if current_user.admin?
                    searchables.reject { |searchable| searchable.instance_of?(Talk) }
                  else
                    searchables.reject do |searchable|
                      searchable.instance_of?(Talk) && searchable.user_id != current_user.id
                    end
                  end

    delete_comment_of_talk!(searchables, current_user)

    searchables.map do |searchable|
      SearchResult.new(searchable, word, current_user)
    end
  end

  def self.fetch_login_name(searchable)
    User.find_by(id: searchable.try(:user_id))&.login_name
  end

  def self.fetch_commentable_user(searchable)
    if searchable.is_a?(Answer) || searchable.is_a?(CorrectAnswer)
      searchable.question&.user
    else
      searchable.try(:commentable)&.try(:user)
    end
  end

  def self.fetch_title(searchable)
    if searchable.is_a?(Answer)
      searchable.question&.title
    elsif searchable.is_a?(User)
      searchable.login_name
    else
      searchable.try(:title)
    end
  end

  def self.fetch_label(searchable)
    if searchable.is_a?(User)
      searchable.avatar_url
    elsif searchable.is_a?(Talk)
      nil
    else
      searchable.label
    end
  end

  def self.result_for_all(words)
    user_filter = words.find { |word| word.match(/^user:(\w+)$/) }
    if user_filter
      username = user_filter.delete_prefix('user:')
      user = User.find_by(login_name: username)
      return [] unless user

      return AVAILABLE_TYPES.reject { |type| type == :users }
                            .flat_map do |type|
                              model = model(type)
                              next [] unless model.column_names.include?('user_id') || model.column_names.include?('last_updated_user_id')
  
                              if type == :practices
                                model.where('last_updated_user_id = ?', user.id)
                              else
                                model.where(user_id: user.id)
                              end
                            end
                            .uniq
                            .select { |result| words.all? { |word| result_matches_keyword?(result, word) } }
                            .sort_by(&:updated_at)
                            .reverse
    else
      results = AVAILABLE_TYPES.flat_map { |type| result_for(type, words) }
                               .uniq
                               .select { |result| words.all? { |word| result_matches_keyword?(result, word) } }
                               .sort_by(&:updated_at)
                               .reverse
      results
    end
  end  

  def self.result_for(type, words, commentable_type: nil)
    raise ArgumentError, "#{type} is not an available type" unless type.in?(AVAILABLE_TYPES)

    if words.blank?
      if commentable?(type)
        return model(type).all + Comment.where(commentable_type: model_name(type)).all
      elsif type == :questions
        return model(type).all + Answer.all + CorrectAnswer.all
      else
        return model(type).all
      end
    end

    if type == :users
      return User.where(
        words.map { |word| "login_name ILIKE ? OR name ILIKE ? OR description ILIKE ?" }
             .join(" AND "),
        *words.flat_map { |word| ["%#{word}%", "%#{word}%", "%#{word}%"] }
      )
    end

    user_filter = words.find { |word| word.match(/^user:(\w+)$/) }
    if user_filter
      username = user_filter.delete_prefix('user:')
      user = User.find_by(login_name: username)
      return [] unless user

      results = if type == :practices
                  model(type).where('user_id = ? OR last_updated_user_id = ?', user.id, user.id)
                else
                  model(type).where(user_id: user.id)
                end
    else
      results = if commentable?(type)
                  model(type).search_by_keywords(words:, commentable_type:) +
                    Comment.search_by_keywords(words:, commentable_type: model_name(type))
                else
                  model(type).search_by_keywords(words:, commentable_type:)
                end
    end
    results.select { |result| words.all? { |word| result_matches_keyword?(result, word) } }
  end

  def self.result_matches_keyword?(result, word)
    return false unless result

    if word =~ /^user:(\w+)$/
      username = Regexp.last_match(1)
      return result.user&.login_name&.casecmp?(username) unless result.is_a?(Practice)

      user = User.find_by(id: result.last_updated_user_id)
      return user&.login_name&.casecmp?(username)
    end

    searchable_fields = [result.try(:title), result.try(:body), result.try(:description)]
    searchable_fields.any? { |field| field.to_s.downcase.include?(word.downcase) }
  end

  def self.result_for_comments(document_type, word)
    [document_type, :comments].flat_map do |type|
      result_for(type, word, commentable_type: model_name(document_type))
    end.uniq.sort_by(&:updated_at).reverse
  end

  def self.result_for_questions(document_type, word)
    [document_type, :answers].flat_map { |type| result_for(type, word) }.sort_by(&:updated_at).reverse
  end

  def self.model(type)
    model_name(type).constantize
  end

  def self.model_name(type)
    type.to_s.camelize.singularize
  end

  def self.commentable?(document_type)
    model(document_type).include?(Commentable)
  end

  def self.delete_comment_of_talk!(searchables, current_user)
    searchables.reject! do |searchable|
      searchable.commentable.user_id != current_user.id && !current_user.admin? if searchable.instance_of?(Comment) && searchable.commentable.instance_of?(Talk)
    end
  end

  def self.highlight_word(text, word)
    return text unless text.present? && word.present?

    sanitized_word = Regexp.escape(word)
    text.gsub(/(#{sanitized_word})/i, '<strong class="matched_word">\1</strong>')
  end
end
