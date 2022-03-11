# frozen_string_literal: true

class Searcher
  DOCUMENT_TYPES = [
    ['すべて', :all],
    ['お知らせ', :announcements],
    ['プラクティス', :practices],
    ['日報', :reports],
    ['提出物', :products],
    ['Q&A', :questions],
    ['Docs', :pages],
    ['イベント', :events],
    ['ユーザー', :users]
  ].freeze

  AVAILABLE_TYPES = DOCUMENT_TYPES.map(&:second) - %i[all] + %i[comments answers]

  class << self
    def search(word, document_type: :all)
      searchables =
        case document_type
        when :all
          result_for_all(word)
        when commentable?
          result_for_comments(document_type, word)
        when :questions
          result_for_questions(document_type, word)
        else
          result_for(document_type, word).sort_by(&:updated_at).reverse
        end

      delete_comment_of_talk!(searchables) # 相談部屋の内容は検索できないようにする
    end

    private

    def result_for(type, word, commentable_type: nil)
      raise ArgumentError "#{type} is not available type" unless type.in?(AVAILABLE_TYPES)

      model(type).search_by_keywords(word: word, commentable_type: commentable_type)
    end

    def commentable?
      ->(document_type) { model(document_type).include?(Commentable) }
    end

    def model(type)
      model_name(type).constantize
    end

    def model_name(type)
      type.to_s.capitalize.singularize
    end

    def result_for_all(word)
      AVAILABLE_TYPES.flat_map { |type| result_for(type, word) }.sort_by(&:updated_at).reverse
    end

    def result_for_comments(document_type, word)
      [document_type, :comments].flat_map do |type|
        result_for(type, word, commentable_type: model_name(document_type))
      end.sort_by(&:updated_at).reverse
    end

    def result_for_questions(document_type, word)
      [document_type, :answers].flat_map { |type| result_for(type, word) }.sort_by(&:updated_at).reverse
    end

    def delete_comment_of_talk!(searchables)
      searchables.reject do |searchable|
        searchable.instance_of?(Comment) && searchable.commentable.instance_of?(Talk)
      end
    end
  end
end
