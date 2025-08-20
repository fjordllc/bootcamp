# frozen_string_literal: true

class Searcher
  DOCUMENT_TYPES = [
    ['すべて', :all], ['お知らせ', :announcements], ['プラクティス', :practices],
    ['日報', :reports], ['提出物', :products], ['Q&A', :questions], ['Docs', :pages],
    ['イベント', :events], ['定期イベント', :regular_events], ['ユーザー', :users]
  ].freeze

  AVAILABLE_TYPES = DOCUMENT_TYPES.map(&:second) - %i[all] + %i[comments answers]

  TYPE_INCLUDES = {
    reports: [:user],
    products: [:user],
    announcements: [:user],
    practices: [],
    pages: [:user],
    events: [:user],
    regular_events: [:user],
    comments: [:user],
    answers: [:user],
    users: []
  }.freeze

  class << self
    include SearchHelper

    def search(word:, current_user:, only_me: false, document_type: :all, page: 1, per_page: 50)
      words = word.to_s.split(/[[:blank:]]+/).reject(&:blank?)
      raw_results = fetch_results(words, document_type, page: page, per_page: per_page) || []
      filtered = filter_results!(raw_results, current_user)

      if only_me
        filtered = filtered.select do |searchable|
          searchable.respond_to?(:user_id) && searchable.user_id == current_user.id
        end
      end

      filtered = delete_private_comment!(filtered)

      total_count = filtered.size
      paged_items = paginate_enumerable(filtered, page: page.to_i, per_page: per_page.to_i)
      results = paged_items.map { |searchable| SearchResult.new(searchable, word, current_user) }

      [results, total_count]
    end

    private

    def result_for_single_model(type, words, page:, per_page:)
      raise ArgumentError, "#{type} is not available" unless type.in?(AVAILABLE_TYPES)

      rel =
        if type == :users
          search_users_relation(words)
        else
          klass = model(type)
          klass.search_by_keywords(words: words)
        end

      if TYPE_INCLUDES.key?(type)
        valid = valid_includes_for(model(type), TYPE_INCLUDES[type])
        rel = valid.any? ? rel.includes(valid) : rel
      end

      rel = rel.order(updated_at: :desc)

      total_count = rel.respond_to?(:count) ? rel.count : rel.to_a.length

      limited = begin
        rel.page(page).per(per_page).to_a
      rescue StandardError
        rel.limit(per_page).offset((page - 1) * per_page).to_a
      end

      [limited, total_count]
    end

    def valid_includes_for(klass, assoc_list)
      return [] if assoc_list.blank? || klass.nil?

      assoc_list.select do |assoc|
        if assoc.is_a?(Hash)
          assoc.keys.all? { |k| klass.reflect_on_association(k).present? }
        else
          klass.reflect_on_association(assoc).present?
        end
      rescue StandardError
        false
      end
    end

    def fetch_results(words, document_type, page: 1, per_page: 50)
      return results_for_all(words, page: page, per_page: per_page) if document_type == :all

      m = model(document_type)
      if m&.include?(Commentable)
        return result_for_comments(document_type, words, page: page, per_page: per_page)
      end

      return result_for_questions(document_type, words) if document_type == :questions

      result_for(document_type, words) || []
    end

    def results_for_all(words, page: 1, per_page: 50)
      user_filter = words.find { |w| w.match(/^user:(\w+)$/) }&.delete_prefix('user:')
      return search_by_user_filter(user_filter, words) if user_filter

      all_results = []

      AVAILABLE_TYPES.each do |type|
        next if type == :users

        rel =
          case type
          when :comments, :answers
            result_for(type, words)
          when :questions
            result_for_questions(type, words)
          else
            result_for_relation(type, words).to_a
          end

        rel = rel.select { |record| words.all? { |w| record_matches_word?(record, w) } }
        all_results.concat(rel)
      end

      all_results.uniq { |r| [r.class.name, r.id] }.sort_by(&:updated_at).reverse
    end

    def record_matches_word?(record, word)
      return false if record.nil?
      record.attributes.values.map(&:to_s).any? { |val| val.include?(word) }
    end

    def result_for_relation(type, words)
      raise ArgumentError, "#{type} is not available" unless type.in?(AVAILABLE_TYPES)
      return search_users_relation(words) if type == :users

      klass = model(type)
      rel = klass.search_by_keywords(words: words)

      if TYPE_INCLUDES.key?(type)
        valid = valid_includes_for(klass, TYPE_INCLUDES[type])
        rel = valid.any? ? rel.includes(valid) : rel
      end

      rel
    end

    def result_for(type, words)
      result_for_relation(type, words).to_a
    end

    def result_for_comments(document_type, words, page:, per_page:)
      results = result_for(document_type, words) || []
      comment_results = result_for(:comments, words)&.select do |comment|
        comment.commentable_type == search_model_name(document_type)
      end || []

      (results + comment_results).select { |r| words.all? { |w| record_matches_word?(r, w) } }
                               .sort_by(&:updated_at).reverse
    end

    def result_for_questions(document_type, words)
      questions = result_for(document_type, words) || []
      answers = result_for(:answers, words) || []
      (questions + answers).select { |r| words.all? { |w| record_matches_word?(r, w) } }
                           .sort_by(&:updated_at).reverse
    end

    def filter_results!(searchables, current_user)
      (searchables || []).select { |searchable| visible_to_user?(searchable, current_user) }
    end

    def delete_private_comment!(searchables)
      (searchables || []).reject do |searchable|
        searchable.is_a?(Comment) && searchable.commentable.class.in?([Talk, Inquiry, CorporateTrainingInquiry])
      end
    end

    def model(type)
      search_model_name(type)&.constantize
    end

    def search_by_user_filter(username, words)
      user = User.find_by(login_name: username) or return []

      models_with_user_id = AVAILABLE_TYPES.select do |type|
        klass = model(type)
        klass&.column_names&.include?('user_id')
      end

      models_with_user_id.flat_map do |type|
        rel = model(type).where(user_id: user.id)
        filter_by_keywords(rel, words)
      end
    end

    def search_users(words)
      User.where(words.map { |_word| 'login_name ILIKE ? OR name ILIKE ? OR description ILIKE ?' }
                      .join(' AND '), *words.flat_map { |word| ["%#{word}%"] * 3 })
    end

    def search_users_relation(words)
      conds = words.map { |_w| '(login_name ILIKE ? OR name ILIKE ? OR description ILIKE ?)' }.join(' AND ')
      args = words.flat_map { |word| ["%#{word}%"] * 3 }
      User.where(conds, *args)
    end

    def paginate_enumerable(enumerable, page:, per_page:)
      page = [page.to_i, 1].max
      per_page = [per_page.to_i, 1].max
      start_index = (page - 1) * per_page
      enumerable[start_index, per_page] || []
    end
  end
end
