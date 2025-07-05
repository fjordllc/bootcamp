# frozen_string_literal: true

class Searcher
  DOCUMENT_TYPES = [
    ['すべて', :all], ['お知らせ', :announcements], ['プラクティス', :practices],
    ['日報', :reports], ['提出物', :products], ['Q&A', :questions],
    ['Docs', :pages], ['イベント', :events], ['定期イベント', :regular_events],
    ['ユーザー', :users]
  ].freeze

  AVAILABLE_TYPES = DOCUMENT_TYPES.map(&:second) - %i[all] + %i[comments answers]

  class << self
    include SearchHelper

    def search(word, current_user:, document_type: :all)
      words = word.split(/[[:blank:]]+/).reject(&:blank?)
      searchables = fetch_results(words, document_type) || []
      searchables = filter_results!(searchables, current_user)
      searchables = delete_private_comment!(searchables)
      searchables.map do |searchable|
        SearchResult.new(searchable, word, current_user)
      end
    end

    private

    def fetch_results(words, document_type)
      return results_for_all(words) if document_type == :all

      model = model(document_type)
      return result_for_comments(document_type, words) if model.include?(Commentable)
      return result_for_questions(document_type, words) if document_type == :questions

      result_for(document_type, words) || []
    end

    def results_for_all(words)
      user_filter = words.find { |word| word.match(/^user:(\w+)$/) }&.delete_prefix('user:')
      return search_by_user_filter(user_filter, words) if user_filter

      AVAILABLE_TYPES.filter_map { |type| result_for(type, words) }
                     .flatten
                     .uniq
                     .sort_by(&:updated_at)
                     .reverse
    end

    def result_for(type, words)
      raise ArgumentError, "#{type} is not available" unless type.in?(AVAILABLE_TYPES)

      return search_users(words) if type == :users
      return model(type).all if words.blank?

      filter_by_keywords(model(type).search_by_keywords(words:), words)
    end

    def result_for_comments(document_type, words)
      results = result_for(document_type, words) || []
      comment_results = result_for(:comments, words)&.select do |comment|
        comment.commentable_type == search_model_name(document_type)
      end || []

      (results + comment_results).sort_by(&:updated_at).reverse
    end

    def result_for_questions(document_type, words)
      (result_for(document_type, words) || []) + (result_for(:answers, words) || [])
                                                 .sort_by(&:updated_at)
                                                 .reverse
    end

    def filter_results!(searchables, current_user)
      searchables&.select { |searchable| visible_to_user?(searchable, current_user) }
    end

    def delete_private_comment!(searchables)
      searchables.reject do |searchable|
        searchable.instance_of?(Comment) && searchable.commentable.class.in?([Talk, Inquiry, CorporateTrainingInquiry])
      end
    end

    def model(type)
      search_model_name(type)&.constantize
    end

    def search_by_user_filter(username, words)
      user = User.find_by(login_name: username) or return []
      filter_by_keywords(search_by_user_id(user.id), words)
    end

    def search_by_user_id(user_id)
      AVAILABLE_TYPES.reject { |type| type == :users }
                     .flat_map { |type| model(type).where(user_filter_condition(type, user_id)) }
    end

    def user_filter_condition(type, user_id)
      type == :practices ? { last_updated_user_id: user_id } : { user_id: }
    end

    def search_users(words)
      User.where(words.map { |_word| 'login_name ILIKE ? OR name ILIKE ? OR description ILIKE ?' }
                      .join(' AND '), *words.flat_map { |word| ["%#{word}%"] * 3 })
    end
  end
end
