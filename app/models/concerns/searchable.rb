# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  class_methods do
    def search_by_keywords(searched_values = {})
      ransack(**params_for_keyword_search(searched_values)).result
    end

    def columns_for_keyword_search(*column_names)
      define_singleton_method(:_join_column_names) { "#{column_names.join("_or_")}_cont_all" }
    end

    private

    def params_for_keyword_search(searched_values = {})
      return {} if searched_values[:word].blank?

      groupings = split_keyword_by_blank(searched_values[:word])
                    .map { |word| word_to_groupings(word) }

      { groupings: groupings }
    end

    def word_to_groupings(word)
      case word
      when /user:(.*)/
        create_parameter_for_search_user_id($1)
      else
        { _join_column_names => word }
      end
    end

    def split_keyword_by_blank(word)
      word.split(/[[:blank:]]/)
    end

    def create_parameter_for_search_user_id(name)
      user = User.find_by(login_name: name)
      { "user_id_eq" => user&.id || 0 }
    end
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
