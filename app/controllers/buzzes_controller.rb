# frozen_string_literal: true

class BuzzesController < ApplicationController
  def index
    @years = Buzz.years
    year = params[:year] || Buzz.latest_year
    @year = year
    @buzzes = Buzz.for_year(year)
  end
end
