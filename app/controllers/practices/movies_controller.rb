# frozen_string_literal: true

class Practices::MoviesController < ApplicationController
  PAGER_NUMBER = 24

  def index
    @practice = Practice.find(params[:practice_id])
    @movies = @practice.movies
                       .includes(:user)
                       .order(updated_at: :desc, id: :desc)
                       .page(params[:page])
                       .per(PAGER_NUMBER)
  end
end
