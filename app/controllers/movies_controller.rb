# frozen_string_literal: true

class MoviesController < ApplicationController
  before_action :set_movie, only: %i[show edit update destroy]
  before_action :set_categories, only: %i[new create edit update]
  before_action :set_wip, only: %i[update]

  PAGER_NUMBER = 24

  def index
    @movies = Movie.includes(:user)
                   .order(updated_at: :desc, id: :desc)
                   .page(params[:page])
                   .per(PAGER_NUMBER)
  end

  def show
    @comments = @movie.comments.order(:created_at)
  end

  def new
    @movie = Movie.new
  end

  def edit; end

  def create
    @movie = Movie.new(movie_params)
    @movie.user = current_user
    set_wip

    if @movie.save
      url = Redirection.determin_url(self, @movie)
      update_published_at
      redirect_to url, notice: notice_message(@movie, :create)
    else
      render :new
    end
  end

  def update
    if @movie.update(movie_params)
      url = Redirection.determin_url(self, @movie)
      update_published_at
      redirect_to url, notice: notice_message(@movie, :update)
    else
      render :edit
    end
  end

  def destroy
    @movie.destroy
    redirect_to movies_path, notice: '動画を削除しました。'
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
      :movie_data,
      :tag_list,
      practice_ids: []
    )
  end

  def set_wip
    @movie.wip = params[:commit] == 'WIP'
  end

  def notice_message(movie, action_name)
    return '動画をWIPとして保存しました。' if movie.wip?

    case action_name
    when :create
      '動画を追加しました。'
    when :update
      '動画を更新しました。'
    end
  end

  def set_movie
    @movie = Movie.find(params[:id])
  end

  def update_published_at
    return if @movie.wip || @movie.published_at?

    @movie.update(published_at: Time.current)
  end
end
