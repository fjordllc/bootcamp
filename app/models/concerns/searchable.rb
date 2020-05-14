# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  class_methods do
    def search_by_keywords(searched_values = {})
      ransack(**params_for_keyword_search(searched_values)).result
    end

    def columns_for_keyword_search(*key_names)
      define_singleton_method(:_grouping_condition) { "#{key_names.map(&:to_s).join("_or_")}_cont_all".to_sym }
    end

    private

      def params_for_keyword_search(searched_values = {})
        return {} if searched_values[:word].blank?
        { groupings: groupings(split_keyword_by_blank(searched_values[:word])) }
      end

      def groupings(words)
        words.map do |word|
          { _grouping_condition => word }
        end
      end

      def split_keyword_by_blank(word)
        word.split(/[[:blank:]]/)
      end
  end

  included do
  end

  def description
    case self
    when Page
      self[:body]
    else
      self[:description]
    end
  end
end
