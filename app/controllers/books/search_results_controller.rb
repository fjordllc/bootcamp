# frozen_string_literal: true

class Books::SearchResultsController < ApplicationController
  before_action :require_login

  def index
    @search_results = Book.search(params[:word]).page(params[:page])
  end
end
