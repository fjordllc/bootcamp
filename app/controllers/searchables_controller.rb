# frozen_string_literal: true

class SearchablesController < ApplicationController
  def index
    result = Searcher.search(params[:word], filter: filter_param)
    @searchables = Kaminari.paginate_array(result).page(params[:page]).per(50)
  end

  def filter_param
    params[:filter]&.to_sym || :all
  end
end
