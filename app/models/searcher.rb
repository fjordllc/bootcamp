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

  AVAILABLE_TYPES = DOCUMENT_TYPES.map(&:second) - [:all] + [:comments] + [:answers]

  class << self
    def search(word, document_type: :all)
      if document_type == :all
        AVAILABLE_TYPES.flat_map { |type| result_for(type, word) }.sort_by { |result| result.created_at }.reverse
      elsif model(document_type).include?(Commentable)
        [document_type, :comments].flat_map { |type| result_for(type, word, commentable_type: model_name(document_type)) }.sort_by { |result| result.created_at }.reverse
      elsif document_type == :questions
        [document_type, :answers].flat_map { |type| result_for(type, word) }
      else
        result_for(document_type, word).sort_by { |result| result.created_at }.reverse
      end
    end

    private

      def result_for(type, word, commentable_type: nil)
        return [] unless available_type?(type)
        type.to_s.capitalize.singularize.constantize.search_by_keywords(word: word, commentable_type: commentable_type)
      end

      def available_type?(type)
        AVAILABLE_TYPES.find { |available_type| available_type == type }.present?
      end

      def model(type)
        model_name(type).constantize
      end

      def model_name(type)
        type.to_s.capitalize.singularize
      end
  end
end
