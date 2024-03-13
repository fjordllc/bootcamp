class MoviesController < ApplicationController

  PAGER_NUMBER = 24

  def index
    @movies = Movie.includes(:user)
    .order(updated_at: :desc)
    .page(params[:page])
    .per(PAGER_NUMBER)
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
