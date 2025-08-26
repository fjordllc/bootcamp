# frozen_string_literal: true

require_relative 'helpers'
require_relative 'select_blocks'

module UnifiedSearch
  class Builder
    include UnifiedSearchHelpers
    include UnifiedSearch::SelectBlocks

    FALLBACK_TITLE_CANDIDATES = %w[title name login_name].freeze
    FALLBACK_BODY_CANDIDATES  = %w[body description].freeze

    def initialize(words:, document_type:, only_me:, current_user_id:)
      @words = Array(words)
      @document_type = document_type
      @only_me = only_me
      @current_user_id = current_user_id
      @cache = {}
    end

    def union_sql
      selects = target_types.map { |t| select_for(t) }.compact
      selects << comments_block if !target_types.include?(:comments) && @document_type != :all
      selects.join("\nUNION ALL\n")
    end

    private

    def select_for(type)
      method_name = "select_for_#{type}"
      respond_to?(method_name, true) ? send(method_name) : nil
    end

    def target_types
      return Searcher::AVAILABLE_TYPES if @document_type == :all

      [@document_type]
    end
  end
end
