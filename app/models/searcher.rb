# frozen_string_literal: true

class Searcher
  DOCUMENT_TYPES = [
    ["すべて", :all],
    ["お知らせ", :announcements],
    ["プラクティス", :practices],
    ["日報", :reports],
    ["Q&A", :questions],
    ["Docs", :pages]
  ]

  AVAILABLE_TYPES = DOCUMENT_TYPES.map(&:second) - %i[all] + %i[comments answers]

  class << self
    def search(word, document_type: :all)
      case document_type
      when :all
        AVAILABLE_TYPES.flat_map { |type| result_for(type, word) }.sort_by(&:updated_at).reverse
      when commentable?
        [document_type, :comments].flat_map { |type| result_for(type, word, commentable_type: model_name(document_type)) }.sort_by(&:updated_at).reverse
      when :questions
        [document_type, :answers].flat_map { |type| result_for(type, word) }.sort_by(&:updated_at).reverse
      else
        result_for(document_type, word).sort_by(&:updated_at).reverse
      end
    end

    private

      def result_for(type, word, commentable_type: nil)
        raise ArgumentError.new("#{type} is not available type") unless type.in?(AVAILABLE_TYPES)
        model(type).search_by_keywords(word: word, commentable_type: commentable_type)
      end

      def commentable?
        -> (document_type) { model(document_type).include?(Commentable) }
      end

      def model(type)
        model_name(type).constantize
      end

      def model_name(type)
        type.to_s.capitalize.singularize
      end
  end
end
