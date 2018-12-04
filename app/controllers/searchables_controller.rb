# frozen_string_literal: true

class SearchablesController < ApplicationController
  def index
    @searchables = Kaminari.paginate_array(Searcher.search(params[:word])).page(params[:page]).per(50)
  end
end
