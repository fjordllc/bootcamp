# frozen_string_literal: true

class API::SearchablesController < API::BaseController
  before_action :require_login

  def index
    result = Searcher.search(params[:word], document_type: document_type_param)
    @searchables = Kaminari.paginate_array(result).page(params[:page]).per(50)
  end

  private

  def document_type_param
    params[:document_type]&.to_sym || :all
  end
end
