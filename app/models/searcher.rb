# frozen_string_literal: true

class Searcher
  attr_reader :keyword, :document_type, :current_user, :only_me

  def self.split_keywords(text)
    text.to_s.split(/[[:blank:]]+/).reject(&:blank?)
  end

  def initialize(keyword:, current_user:, document_type: :all, only_me: false)
    @keyword = keyword.to_s.strip
    @document_type = validate_document_type(document_type)
    @only_me = only_me
    @current_user = current_user
  end

  def search
    return [] if keyword.blank?

    query_builder = QueryBuilder.new(keyword)
    type_searcher = TypeSearcher.new(query_builder, document_type)
    filter = Filter.new(current_user, only_me:)

    results = type_searcher.search
    filter.apply(results)
  end

  private

  def validate_document_type(document_type)
    type_sym = document_type&.to_sym || :all
    available_keys = Configuration.available_types + [:all]

    return type_sym if available_keys.include?(type_sym)

    raise ArgumentError, "Invalid document_type: #{document_type}. Available types: #{available_keys.join(', ')}"
  end
end
