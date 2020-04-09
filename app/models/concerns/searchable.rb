# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  class_methods do
    def search_by_keywords(searched_values = {})
      ransack(**params_for_keyword_search(searched_values)).result
    end

    private

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
