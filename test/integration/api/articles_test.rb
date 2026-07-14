# frozen_string_literal: true

require 'test_helper'

class API::ArticlesTest < ActionDispatch::IntegrationTest
  def setup
    application = Doorkeeper::Application.create!(
      name: 'Article API Test',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
    )
    @admin = users(:komagata)
    @mentor = users(:mentormentaro)
    @student = users(:kimura)
    @admin_token = create_access_token(application, @admin, 'read write')
    @admin_read_token = create_access_token(application, @admin, 'read')
    @mentor_token = create_access_token(application, @mentor, 'read write')
    @student_token = create_access_token(application, @student, 'read write')
  end

  test 'requires login for article API' do
    get api_articles_path(format: :json)
    assert_response :unauthorized

    get api_article_path(articles(:article1), format: :json)
    assert_response :unauthorized

    post api_articles_path(format: :json), params: { article: valid_article_params }
    assert_response :unauthorized
  end

  test 'logged-in user can get published articles and filter them by tag' do
    tagged_article = articles(:article1)
    tagged_article.tag_list = ['API確認用']
    tagged_article.save!

    get api_articles_path(format: :json), headers: authorization_header(@student_token)

    assert_response :ok
    article_ids = response.parsed_body['articles'].pluck('id')
    assert_includes article_ids, tagged_article.id
    assert_not_includes article_ids, articles(:article3).id
    assert response.parsed_body['total_pages'].positive?

    get api_articles_path(format: :json, tag: 'API確認用'), headers: authorization_header(@student_token)

    assert_response :ok
    assert_equal [tagged_article.id], response.parsed_body['articles'].pluck('id')
  end

  test 'logged-in user can get a published article' do
    article = articles(:article1)

    get api_article_path(article, format: :json), headers: authorization_header(@student_token)

    assert_response :ok
    assert_equal article.id, response.parsed_body['id']
    assert_equal article.title, response.parsed_body['title']
    assert_equal article.body, response.parsed_body['body']
    assert_equal article.user.login_name, response.parsed_body.dig('user', 'login_name')
    assert response.parsed_body.key?('thumbnail_url')
  end

  test 'only admin or mentor can get the WIP list' do
    get api_articles_path(format: :json, wip: true), headers: authorization_header(@student_token)
    assert_response :forbidden

    get api_articles_path(format: :json, wip: true), headers: authorization_header(@mentor_token)

    assert_response :ok
    article_ids = response.parsed_body['articles'].pluck('id')
    assert_includes article_ids, articles(:article3).id
    assert(response.parsed_body['articles'].all? { |article| article['wip'] })
  end

  test 'logged-in user can preview WIP article with its token' do
    article = articles(:article3)

    get api_article_path(article, format: :json), headers: authorization_header(@student_token)
    assert_response :forbidden

    get api_article_path(article, format: :json, token: article.token), headers: authorization_header(@student_token)

    assert_response :ok
    assert_equal article.id, response.parsed_body['id']
    assert_nil response.parsed_body['token']
  end

  test 'admin and mentor can create articles' do
    [@admin_token, @mentor_token].each do |token|
      assert_difference('Article.count') do
        post api_articles_path(format: :json),
             headers: authorization_header(token),
             params: { article: valid_article_params }
      end

      assert_response :created
      assert_equal 'APIから作成した記事', response.parsed_body['title']
      assert_equal %w[API 記事], response.parsed_body['tags']
      assert_not response.parsed_body['wip']
      assert response.parsed_body['published_at'].present?
    end
  end

  test 'can specify an admin or mentor as the contributor' do
    post api_articles_path(format: :json),
         headers: authorization_header(@admin_token),
         params: { article: valid_article_params.merge(user_id: @mentor.id) }

    assert_response :created
    assert_equal @mentor.id, response.parsed_body.dig('user', 'id')
    assert_equal @mentor, Article.find(response.parsed_body['id']).user
  end

  test 'cannot specify a student as the contributor' do
    assert_no_difference('Article.count') do
      post api_articles_path(format: :json),
           headers: authorization_header(@admin_token),
           params: { article: valid_article_params.merge(user_id: @student.id) }
    end

    assert_response :unprocessable_entity
    assert response.parsed_body.dig('errors', 'user_id').present?
  end

  test 'can create and replace a custom thumbnail using multipart form data' do
    thumbnail = fixture_file_upload('articles/ogp_images/test.jpg', 'image/jpeg')

    post api_articles_path(format: :json),
         headers: authorization_header(@admin_token),
         params: {
           article: valid_article_params.merge(
             thumbnail_type: 'prepared_thumbnail',
             thumbnail:,
             display_thumbnail_in_body: true,
             published_at: '2026-07-01T12:34:56+09:00',
             wip: true
           )
         }

    assert_response :created
    article = Article.find(response.parsed_body['id'])
    assert article.thumbnail.attached?
    assert_nil article.published_at
    assert response.parsed_body['thumbnail_attached']
    assert response.parsed_body['display_thumbnail_in_body']
    assert_equal 'prepared_thumbnail', response.parsed_body['thumbnail_type']
    assert response.parsed_body['token'].present?

    replacement = fixture_file_upload('articles/ogp_images/test.jpg', 'image/jpeg')
    patch api_article_path(article, format: :json),
          headers: authorization_header(@admin_token),
          params: { article: { thumbnail: replacement } }

    assert_response :ok
    assert article.reload.thumbnail.attached?
  end

  test 'can update and publish a WIP article' do
    article = articles(:article3)

    patch api_article_path(article, format: :json),
          headers: authorization_header(@mentor_token),
          params: {
            article: {
              title: 'APIから更新したWIP記事',
              tag_list: %w[更新 公開],
              display_thumbnail_in_body: false,
              wip: false
            }
          }

    assert_response :ok
    article.reload
    assert_equal 'APIから更新したWIP記事', article.title
    assert_equal %w[更新 公開], article.tag_list
    assert_not article.wip?
    assert article.published_at.present?
  end

  test 'can change published at of a published article' do
    article = articles(:article1)
    published_at = '2026-07-01T12:34:56+09:00'

    patch api_article_path(article, format: :json),
          headers: authorization_header(@admin_token),
          params: { article: { published_at: } }

    assert_response :ok
    assert_equal Time.zone.parse(published_at), article.reload.published_at
  end

  test 'returns validation errors as JSON' do
    assert_no_difference('Article.count') do
      post api_articles_path(format: :json),
           headers: authorization_header(@admin_token),
           params: { article: valid_article_params.merge(title: '', body: '') }
    end

    assert_response :unprocessable_entity
    assert response.parsed_body.dig('errors', 'title').present?
    assert response.parsed_body.dig('errors', 'body').present?
  end

  test 'student cannot create update or destroy articles' do
    article = articles(:article1)

    post api_articles_path(format: :json),
         headers: authorization_header(@student_token),
         params: { article: valid_article_params }
    assert_response :forbidden

    patch api_article_path(article, format: :json),
          headers: authorization_header(@student_token),
          params: { article: { title: '更新できない記事' } }
    assert_response :forbidden

    assert_no_difference('Article.count') do
      delete api_article_path(article, format: :json), headers: authorization_header(@student_token)
    end
    assert_response :forbidden
  end

  test 'write operations require write scope' do
    post api_articles_path(format: :json),
         headers: authorization_header(@admin_read_token),
         params: { article: valid_article_params }

    assert_response :forbidden
    assert_equal 'invalid_scope', response.parsed_body['error']
  end

  test 'admin can destroy an article' do
    article = articles(:article1)

    assert_difference('Article.count', -1) do
      delete api_article_path(article, format: :json), headers: authorization_header(@admin_token)
    end

    assert_response :no_content
  end

  test 'returns not found as JSON' do
    get api_article_path('missing', format: :json), headers: authorization_header(@student_token)

    assert_response :not_found
    assert_equal '記事が見つかりません。', response.parsed_body['message']
  end

  test 'admin or mentor can generate an article summary' do
    Article.stub(:agent_summary, { summary: 'APIで生成した概要' }) do
      post api_articles_summary_path(format: :json),
           headers: authorization_header(@admin_token),
           params: { body: '概要を生成する記事本文' }
    end

    assert_response :ok
    assert_equal 'APIで生成した概要', response.parsed_body['summary']
  end

  private

  def create_access_token(application, user, scopes)
    Doorkeeper::AccessToken.create!(application:, resource_owner_id: user.id, scopes:)
  end

  def authorization_header(token)
    { Authorization: "Bearer #{token.token}" }
  end

  def valid_article_params
    {
      title: 'APIから作成した記事',
      body: 'APIから作成した記事の本文です。',
      summary: 'APIから作成した記事の概要です。',
      tag_list: %w[API 記事],
      thumbnail_type: 'ruby_on_rails',
      display_thumbnail_in_body: true,
      target: 'none',
      wip: false
    }
  end
end
