# frozen_string_literal: true

class API::SmartSearchablesController < API::BaseController
  PAGER_NUMBER = 50

  def index
    if params[:smart_search].present? && params[:smart_search] == 'true'
      smart_search_results
    else
      fallback_to_keyword_search
    end
  end

  private

  def smart_search_results
    searcher = SmartSearch::SemanticSearcher.new

    result = if params[:hybrid].present? && params[:hybrid] == 'true'
               searcher.hybrid_search(
                 params[:word],
                 document_type: document_type_param,
                 limit: PAGER_NUMBER
               )
             else
               searcher.search(
                 params[:word],
                 document_type: document_type_param,
                 limit: PAGER_NUMBER
               )
             end

    @searchables = Kaminari.paginate_array(result).page(params[:page]).per(PAGER_NUMBER)

    render 'api/searchables/index'
  rescue StandardError => e
    Rails.logger.error "SmartSearch error: #{e.message}"
    fallback_to_keyword_search
  end

  def fallback_to_keyword_search
    result = Searcher.search(params[:word], document_type: document_type_param)
    @searchables = Kaminari.paginate_array(result).page(params[:page]).per(PAGER_NUMBER)

    render 'api/searchables/index'
  end

  def document_type_param
    params[:document_type]&.to_sym || :all
  end
end
