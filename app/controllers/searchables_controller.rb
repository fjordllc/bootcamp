# frozen_string_literal: true

class SearchablesController < ApplicationController
  def index
    @per = 50
    @word = params[:word]
    @page_number = params[:page].present? ? params[:page].to_i : 1
    request_params = params.permit(:document_type, :word).to_h.to_query
    @url = "/api/searchables.json?#{request_params}"
    @error = nil
    # @data = []
  end
end
