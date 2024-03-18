# frozen_string_literal: true

require 'streamio-ffmpeg'

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

    ActiveRecord::Base.transaction do
      if @movie.save
        redirect_to @movie, notice: '動画を追加しました。'
  
        movie_blob = params[:movie][:movie_data].tempfile.path
        thumbnail_blob = generate_thumbnail_from_blob(movie_blob)

        if thumbnail_blob
          @movie.thumbnail.attach(thumbnail_blob)
        else
          raise ActiveRecord::Rollback, "サムネイルの添付に失敗しました。"
        end
      else
        render :new, notice: '動画の追加に失敗しました。'
      end
    end
  rescue ActiveRecord::Rollback => e
    redirect_to new_movie_path, alert: e.message
  end

  def generate_thumbnail_from_blob(movie_blob)
    movie_path = params[:movie][:movie_data].tempfile.path
    thumbnail_path = Tempfile.new(['thumbnail', '.png']).path

    movie = FFMPEG::Movie.new(movie_path)
    movie.screenshot(thumbnail_path, { seek_time: 5, vframes: 1 })

    thumbnail_blob = ActiveStorage::Blob.create_after_upload!(
      io: File.open(thumbnail_path),
      filename: 'thumbnail.jpg',
      content_type: 'image/jpeg'
    )
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
      :movie_data,
      :practice_id
    )
  end
end
