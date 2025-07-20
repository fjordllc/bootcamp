# frozen_string_literal: true

class SmartSearchablesController < ApplicationController
  include SearchHelper

  PAGER_NUMBER = 20

  def index
    @query = params[:word]&.strip

    if @query.present?
      perform_smart_search
    else
      @searchables = []
      @search_performed = false
    end
  end

  private

  def perform_smart_search
    @search_performed = true
    searcher = SmartSearch::SemanticSearcher.new

    begin
      result = if params[:hybrid].present? && params[:hybrid] == 'true'
                 searcher.hybrid_search(
                   @query,
                   document_type: document_type_param,
                   limit: PAGER_NUMBER
                 )
               else
                 searcher.search(
                   @query,
                   document_type: document_type_param,
                   limit: PAGER_NUMBER
                 )
               end

      @searchables = Kaminari.paginate_array(result).page(params[:page]).per(PAGER_NUMBER)
      @search_type = 'smart'
    rescue StandardError => e
      Rails.logger.error "SmartSearch error: #{e.message}"
      fallback_to_keyword_search
    end
  end

  def fallback_to_keyword_search
    result = Searcher.search(@query, document_type: document_type_param)
    @searchables = Kaminari.paginate_array(result).page(params[:page]).per(PAGER_NUMBER)
    @search_type = 'keyword'
  end

  def document_type_param
    params[:document_type]&.to_sym || :all
  end
end
