class MoviesController < ApplicationController
  before_action :set_categories, only: %i[new create]

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

  def set_categories
    @categories =
      Category
      .eager_load(:practices, :categories_practices)
      .where.not(practices: { id: nil })
      .order('categories_practices.position')
  end

  def movie_params
    params.require(:movie).permit(
      :title,
      :description,
      :tag_list,
      :movie_data
    )
  end

end
