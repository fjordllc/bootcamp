# frozen_string_literal: true

class Page < ActiveRecord::Base
  include Searchable

  validates :title, presence: true
  validates :body, presence: true
  paginates_per 20

  concerning :KeywordSearch do
    class_methods do
      private

        def params_for_keyword_search(searched_values = {})
          { groupings: groupings(split_keyword_by_blank(searched_values[:word])) }
        end

        def groupings(words)
          words.map do |word|
            { title_or_body_cont_all: word }
          end
        end
    end
  end
end
