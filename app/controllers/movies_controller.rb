# frozen_string_literal: true

require 'streamio-ffmpeg'

class MoviesController < ApplicationController
  before_action :set_movie, only: %i[show edit update destroy]
  before_action :set_categories, only: %i[new create edit update]

  PAGER_NUMBER = 24

  def index
    @movies = Movie.includes(:user)
                   .order(updated_at: :desc, id: :desc)
                   .page(params[:page])
                   .per(PAGER_NUMBER)
  end

  def show; end

  def new
    @movie = Movie.new
  end

  def edit; end

  def create
    @movie = Movie.new(movie_params)
    @movie.last_updated_user = current_user
    @movie.user = current_user
    set_wip

    ActiveRecord::Base.transaction do
      if @movie.save
        update_published_at
        url = Redirection.determin_url(self, @movie)
        redirect_to url, notice: notice_message(@movie, :create)

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

  def update
    set_wip
    @movie.last_updated_user = current_user
    if @movie.update(movie_params)
      url = Redirection.determin_url(self, @movie)
      update_published_at
      redirect_to url, notice: notice_message(@movie, :update)
    else
      render :edit, notice: '動画の更新に失敗しました。'
    end
  end

  def destroy
    @movie.destroy
    redirect_to '/movies', notice: '動画を削除しました。'
  end

  private

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
    params.require(:movie).permit(:practice_id, :title, :description, :movie_data, :tag_list)
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
