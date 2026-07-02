# frozen_string_literal: true

require 'test_helper'

class API::MoviesTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:kimura)
    application = Doorkeeper::Application.create!(
      name: 'Sample Application',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
    )
    @read_token = Doorkeeper::AccessToken.create!(
      application:,
      resource_owner_id: @user.id,
      scopes: 'read'
    )
    @write_token = Doorkeeper::AccessToken.create!(
      application:,
      resource_owner_id: @user.id,
      scopes: 'read write'
    )
  end

  test 'POST /api/movies.json creates movie with uploaded movie data' do
    movie_data = fixture_file_upload('movies/movie.mp4', 'video/mp4')
    thumbnail = fixture_file_upload('articles/ogp_images/test.jpg', 'image/jpeg')

    assert_difference('Movie.count') do
      assert_enqueued_with(job: TranscodeJob) do
        assert_enqueued_with(job: GenerateMovieThumbnailJob) do
          post api_movies_path(format: :json),
               headers: { Authorization: "Bearer #{@write_token.token}" },
               params: {
                 movie: {
                   title: 'APIで作成した動画',
                   description: 'APIから動画をアップロードしました。',
                   movie_data:,
                   thumbnail:,
                   tag_list: 'API,動画',
                   practice_ids: [practices(:practice1).id],
                   wip: false
                 }
               }
        end
      end
    end

    assert_response :created
    movie = Movie.find(response.parsed_body['id'])
    assert_equal @user, movie.user
    assert_equal 'APIで作成した動画', movie.title
    assert_equal 'APIから動画をアップロードしました。', movie.description
    assert movie.movie_data.attached?
    assert movie.thumbnail.attached?
    assert_not movie.wip?
    assert_not_nil movie.published_at
    assert_equal [practices(:practice1).id], movie.practice_ids
    assert_equal %w[API 動画], movie.tag_list
    assert_equal movie.title, response.parsed_body['title']
    assert_equal movie.practice_ids, response.parsed_body['practice_ids']
  end

  test 'POST /api/movies.json creates movie with direct uploaded blob signed id' do
    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join('test/fixtures/files/movies/movie.mp4')),
      filename: 'movie.mp4',
      content_type: 'video/mp4'
    )

    assert_difference('Movie.count') do
      post api_movies_path(format: :json),
           headers: { Authorization: "Bearer #{@write_token.token}" },
           params: {
             movie: {
               title: 'APIで作成した大きい動画',
               description: 'direct upload済みの動画を登録しました。',
               movie_data: blob.signed_id
             }
           }
      assert_response :created
    end

    movie = Movie.find(response.parsed_body['id'])
    assert_equal blob, movie.movie_data.blob
    assert_equal blob.byte_size, movie.movie_data.byte_size
  end

  test 'POST /api/movies/direct_uploads.json returns direct upload data for movie' do
    assert_difference('ActiveStorage::Blob.count') do
      post direct_uploads_api_movies_path(format: :json),
           headers: { Authorization: "Bearer #{@write_token.token}" },
           params: {
             blob: {
               filename: 'large_movie.mp4',
               byte_size: 5.gigabytes,
               checksum: '1B2M2Y8AsgTpgAmY7PhCfg==',
               content_type: 'video/mp4'
             }
           }
      assert_response :created
    end

    assert_equal 'large_movie.mp4', response.parsed_body['filename']
    assert_equal 'video/mp4', response.parsed_body['content_type']
    assert_equal 5.gigabytes, response.parsed_body['byte_size']
    assert response.parsed_body['signed_id'].present?
    assert response.parsed_body.dig('direct_upload', 'url').present?
    assert_kind_of Hash, response.parsed_body.dig('direct_upload', 'headers')
  end

  test 'POST /api/movies/direct_uploads.json with read scope returns forbidden' do
    assert_no_difference('ActiveStorage::Blob.count') do
      post direct_uploads_api_movies_path(format: :json),
           headers: { Authorization: "Bearer #{@read_token.token}" },
           params: { blob: direct_upload_params }
    end

    assert_response :forbidden
  end

  test 'POST /api/movies/direct_uploads.json rejects non movie content type' do
    assert_no_difference('ActiveStorage::Blob.count') do
      post direct_uploads_api_movies_path(format: :json),
           headers: { Authorization: "Bearer #{@write_token.token}" },
           params: { blob: direct_upload_params.merge(content_type: 'image/jpeg') }
    end

    assert_response :bad_request
    assert_equal '動画ファイルは mp4 または mov を指定してください。', response.parsed_body['message']
  end

  test 'POST /api/movies.json with read scope returns forbidden' do
    assert_no_difference('Movie.count') do
      post api_movies_path(format: :json),
           headers: { Authorization: "Bearer #{@read_token.token}" },
           params: { movie: valid_movie_params }
    end

    assert_response :forbidden
  end

  test 'POST /api/movies.json returns validation errors' do
    assert_no_difference('Movie.count') do
      post api_movies_path(format: :json),
           headers: { Authorization: "Bearer #{@write_token.token}" },
           params: { movie: valid_movie_params.merge(title: '') }
    end

    assert_response :unprocessable_entity
    assert_includes response.parsed_body.dig('errors', 'title'), 'を入力してください'
  end

  private

  def valid_movie_params
    {
      title: 'APIで作成した動画',
      description: 'APIから動画をアップロードしました。',
      movie_data: fixture_file_upload('movies/movie.mp4', 'video/mp4')
    }
  end

  def direct_upload_params
    {
      filename: 'large_movie.mp4',
      byte_size: 5.gigabytes,
      checksum: '1B2M2Y8AsgTpgAmY7PhCfg==',
      content_type: 'video/mp4'
    }
  end
end
