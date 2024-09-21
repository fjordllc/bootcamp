# frozen_string_literal: true

class SearchablesController < ApplicationController
  def index
    @per = 50
    @word = params[:word]
    @page_number = params[:page].present? ? params[:page].to_i : 1
    @error = nil

    begin
      response = RestClient.get('/api/searchables.json', { params: { word: @word, page: @page_number, per: @per } })
      @data = JSON.parse(response.body)
    rescue RestClient::ExceptionWithResponse => e
      @error = e.response
      @data = nil
    end
  end
end
