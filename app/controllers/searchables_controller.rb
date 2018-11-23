# frozen_string_literal: true

class SearchablesController < ApplicationController
  def index
    @searchables = Search.search(params[:word])
  end
end
