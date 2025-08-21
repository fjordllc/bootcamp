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

    def search(word:, current_user:, only_me: false, document_type: :all)
      words = word.split(/[[:blank:]]+/).reject(&:blank?)
      searchables = filter_results!(fetch_results(words, document_type), current_user)

      if only_me
        skip_classes = %w[Practice User]
        searchables = searchables
                      .reject { |s| s.class.name.in?(skip_classes) }
                      .select { |s| s.user_id == current_user.id }
      end

      delete_private_comment!(searchables).map { |s| SearchResult.new(s, word, current_user) }
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
      if (user_filter = extract_user_filter(words))
        return search_by_user_filter(user_filter, words)
      end

      results = AVAILABLE_TYPES.flat_map { |type| result_for(type, words).to_a }
      users = search_users(words).to_a
      (results + users).uniq.sort_by(&:updated_at).reverse
    end

    def result_for(type, words)
      raise ArgumentError, "#{type} is not available" unless type.in?(AVAILABLE_TYPES)
      if type == :users
        return words.blank? ? User.all : search_users(words)
      end

      klass = model(type)
      return klass.all if words.blank?

      apply_word_filters(klass.all, klass, words).order(updated_at: :desc)
    end

    def result_for_comments(document_type, words)
      (result_for(document_type, words).to_a + comments_for(document_type, words)).sort_by(&:updated_at).reverse
    end

    def result_for_questions(document_type, words)
      (result_for(document_type, words).to_a + result_for(:answers, words).to_a).sort_by(&:updated_at).reverse
    end

    def apply_word_filters(query, klass, words)
      words.reduce(query) do |q, word|
        word.start_with?('user:') ? apply_user_filter(q, word) : apply_column_filter(q, klass, word)
      end
    end

    def apply_user_filter(query, word)
      user = User.find_by(login_name: word.delete_prefix('user:'))
      user ? query.where(user_id: user.id) : query
    end

    def apply_column_filter(query, klass, word)
      cols = klass.column_names & %w[title body description]
      return query if cols.empty?

      query.where(cols.map { |c| "#{c} ILIKE :word" }.join(' OR '), word: "%#{word}%")
    end

    def comments_for(document_type, words)
      result_for(:comments, words)&.select { |c| c.commentable_type == search_model_name(document_type) } || []
    end

    def filter_results!(searchables, current_user)
      searchables&.select { |s| visible_to_user?(s, current_user) }
    end

    def delete_private_comment!(searchables)
      searchables.reject do |s|
        s.instance_of?(Comment) && s.commentable.class.in?([Talk, Inquiry, CorporateTrainingInquiry])
      end
    end

    def model(type) = search_model_name(type)&.constantize

    def extract_user_filter(words) = words.find { |w| w.match(/^user:(\w+)$/) }&.delete_prefix('user:')

    def search_by_user_filter(username, words)
      user = User.find_by(login_name: username) or return []
      filter_by_keywords(search_by_user_id(user.id), words)
    end

    def search_by_user_id(user_id)
      AVAILABLE_TYPES.reject { |t| t == :users }.flat_map { |t| model(t).where(user_filter_condition(t, user_id)).to_a }
    end

    def user_filter_condition(type, user_id) = (type == :practices ? { last_updated_user_id: user_id } : { user_id: })

    def search_users(words)
      User.where(
        words.map { |_w| 'login_name ILIKE ? OR name ILIKE ? OR description ILIKE ?' }.join(' AND '),
        *words.flat_map { |w| ["%#{w}%"] * 3 }
      )
    end
  end
end
