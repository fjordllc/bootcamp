# frozen_string_literal: true

class SearchablesController < ApplicationController
  PER_PAGE = 50

  def index
    @word = params[:word].to_s
    @document_type = params[:document_type]&.to_sym || :all

    result = Searcher.search(@word, document_type: @document_type, current_user: current_user)
    @searchables = Kaminari.paginate_array(result.uniq).page(params[:page]).per(PER_PAGE)
  end
end
