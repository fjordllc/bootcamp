# frozen_string_literal: true

class API::MoviesController < API::BaseController
  before_action :set_movie, only: %i[update]

  def index; end

  def update
    if @movie.update(movie_params)
      head :ok
    else
      head :bad_request
    end
  end

  private

  def set_movie
    @movie = Movie.find(params[:id])
  end

  def movie_params
    params.require(:movie).permit(:tag_list)
  end
end
