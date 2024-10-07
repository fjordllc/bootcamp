# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

class SearchablesController < ApplicationController
  def index
    @per = 50
    @word = params[:word]
    @page_number = params[:page].present? ? params[:page].to_i : 1
    request_params = params.permit(:document_type, :word, :page).to_h.to_query
    @url = "/api/searchables.json?#{request_params}"
  end
end
