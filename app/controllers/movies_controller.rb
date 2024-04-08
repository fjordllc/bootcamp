# frozen_string_literal: true

require 'streamio-ffmpeg'

class MoviesController < ApplicationController
  before_action :set_categories, only: %i[new create]

  PAGER_NUMBER = 24

  def index
    @movies = Movie.includes(:user)
                   .order(created_at: :desc)
                   .page(params[:movie])
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

    ActiveRecord::Base.transaction do
      if @movie.save
        redirect_to @movie, notice: '動画を追加しました。'

        movie_path = save_blob_to_tempfile(@movie.movie_data.blob)
        thumbnail_blob = generate_thumbnail_from_blob(movie_path)

        raise ActiveRecord::Rollback, 'サムネイルの添付に失敗しました。' unless thumbnail_blob

        @movie.thumbnail.attach(thumbnail_blob)

      else
        render :new, notice: '動画の追加に失敗しました。'
      end
    end
  rescue ActiveRecord::Rollback => e
    redirect_to new_movie_path, alert: e.message
  end

  def generate_thumbnail_from_blob(movie_path)
    thumbnail_path = Tempfile.new(['thumbnail', '.png']).path

    movie = FFMPEG::Movie.new(movie_path)
    movie.screenshot(thumbnail_path, { seek_time: 0, vframes: 1 })

    ActiveStorage::Blob.create_after_upload!(
      io: File.open(thumbnail_path),
      filename: 'thumbnail.jpg',
      content_type: 'image/jpeg'
    )
  end

  private

  def save_blob_to_tempfile(blob)
    tempfile = Tempfile.new(["#{blob.filename}.#{blob.filename.extension}", ''], 'tmp/', binmode: true)
    tempfile.write(blob.download)
    tempfile.rewind
    tempfile.path
  end

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
