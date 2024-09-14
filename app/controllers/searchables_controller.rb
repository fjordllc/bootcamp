# frozen_string_literal: true

class SearchablesController < ApplicationController
  def index
    @per = 50
    @word = params[:word]
    @error = nil
    # @data = fetch_searchables(params[:word], @page, @per)
    # @error = @data.nil?
  end
end
