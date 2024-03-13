class MoviesController < ApplicationController
  def index
    @movies = Movie.order(created_at: :desc)
  end

  def new
    @movie = Movie.new
  end

  def create
    @movie = Movie.new(movie_params)
    @movie.user = current_user
    if @movie.save
      redirect_to @movie, notice: '動画を追加しました。'
    else
      render :new
    end
  end


  private
  def movie_params
    params.require(:movie).permit(
      :title,
      :description,
      :tags,
      :public_scope,
      :movie_data
    )
  end

end
