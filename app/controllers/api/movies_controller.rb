# frozen_string_literal: true

class API::MoviesController < API::BaseController
  before_action -> { doorkeeper_authorize! :write }, only: %i[create direct_uploads], if: -> { doorkeeper_token.present? }
  before_action :set_movie, only: %i[update]

  MOVIE_CONTENT_TYPES = %w[video/mp4 video/quicktime].freeze

  def index; end

  def create
    @movie = current_user.movies.new(create_movie_params.except(:wip))
    apply_wip
    update_published_at

    if @movie.save
      render json: movie_json, status: :created
    else
      render json: { errors: @movie.errors }, status: :unprocessable_entity
    end
  end

  def direct_uploads
    return render_bad_request('動画ファイルは mp4 または mov を指定してください。') unless movie_content_type?

    blob = ActiveStorage::Blob.create_before_direct_upload!(**direct_upload_params.to_h.symbolize_keys)
    render json: direct_upload_json(blob), status: :created
  end

  def update
    if @movie.update(update_movie_params)
      head :ok
    else
      head :bad_request
    end
  end

  private

  def set_movie
    @movie = Movie.find(params[:id])
  end

  def create_movie_params
    params.require(:movie).permit(
      :title,
      :description,
      :movie_data,
      :thumbnail,
      :tag_list,
      :wip,
      practice_ids: []
    )
  end

  def update_movie_params
    params.require(:movie).permit(:tag_list)
  end

  def direct_upload_params
    params.require(:blob).permit(:filename, :byte_size, :checksum, :content_type, metadata: {})
  end

  def movie_content_type?
    MOVIE_CONTENT_TYPES.include?(direct_upload_params[:content_type])
  end

  def direct_upload_json(blob)
    blob.as_json(root: false, methods: :signed_id).merge(
      direct_upload: {
        url: blob.service_url_for_direct_upload,
        headers: blob.service_headers_for_direct_upload
      }
    )
  end

  def apply_wip
    return unless create_movie_params.key?(:wip)

    @movie.wip = ActiveModel::Type::Boolean.new.cast(create_movie_params[:wip])
  end

  def update_published_at
    return if @movie.wip? || @movie.published_at?

    @movie.published_at = Time.current
  end

  def movie_json
    {
      id: @movie.id,
      title: @movie.title,
      description: @movie.description,
      user_id: @movie.user_id,
      wip: @movie.wip,
      published_at: @movie.published_at,
      practice_ids: @movie.practice_ids,
      tag_list: @movie.tag_list
    }
  end
end
