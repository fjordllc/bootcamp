# frozen_string_literal: true

class MoviesController < ApplicationController
  before_action :set_categories, only: %i[new create]

  PAGER_NUMBER = 24

  def index
    @movies = Movie.includes(:user)
                   .order(created_at: :desc)
                   .page(params[:page])
                   .per(PAGER_NUMBER)
  end

  def show
    @movie = Movie.find(params[:id])
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
      render :new, notice: '動画の追加に失敗しました。'
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
      :practice_id,
      :title,
      :description,
      :movie_data,
      :tag_list
    )
  end
end
