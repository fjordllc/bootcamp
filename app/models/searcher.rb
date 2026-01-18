# frozen_string_literal: true

class Searcher
  MODES = %i[keyword semantic hybrid].freeze
  MODES_FOR_SELECT = [
    %w[キーワード検索 keyword],
    %w[AI検索 semantic],
    %w[ハイブリッド hybrid]
  ].freeze

  attr_reader :keyword, :document_type, :current_user, :only_me, :mode

  def self.split_keywords(text)
    text.to_s.split(/[[:blank:]]+/).reject(&:blank?)
  end

  def initialize(keyword:, current_user:, document_type: :all, only_me: false, mode: :keyword)
    @keyword = keyword.to_s.strip
    @document_type = validate_document_type(document_type)
    @only_me = only_me
    @current_user = current_user
    @mode = validate_mode(mode)
  end

  def search
    return [] if keyword.blank?

    results = case mode
              when :keyword then keyword_search
              when :semantic then semantic_search
              when :hybrid then hybrid_search
              end

    filter = Filter.new(current_user, only_me:)
    filter.apply(results)
  end

  private

  def keyword_search
    query_builder = QueryBuilder.new(keyword)
    type_searcher = TypeSearcher.new(query_builder, document_type)
    type_searcher.search
  end

  def semantic_search
    searcher = SmartSearch::SemanticSearcher.new
    searcher.search(keyword, document_type:)
  end

  def hybrid_search
    keyword_results = keyword_search
    semantic_results = semantic_search

    merge_results(semantic_results, keyword_results)
  end

  def merge_results(primary, secondary)
    seen_ids = {}
    merged = []

    primary.each do |record|
      key = "#{record.class.name}-#{record.id}"
      next if seen_ids[key]

      merged << record
      seen_ids[key] = true
    end

    secondary.each do |record|
      key = "#{record.class.name}-#{record.id}"
      next if seen_ids[key]

      merged << record
      seen_ids[key] = true
    end

    merged
  end

  def validate_document_type(document_type)
    type_sym = document_type&.to_sym || :all
    available_keys = Configuration.available_types + [:all]

    return type_sym if available_keys.include?(type_sym)

    raise ArgumentError, "Invalid document_type: #{document_type}. Available types: #{available_keys.join(', ')}"
  end

  def validate_mode(mode)
    mode_sym = mode&.to_sym || :keyword
    return mode_sym if MODES.include?(mode_sym)

    :keyword
  end
end
