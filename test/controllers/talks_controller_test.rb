# frozen_string_literal: true

require 'test_helper'

class TalksControllerTest < ActionDispatch::IntegrationTest
  test 'talks do not define their own comments route' do
    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path('/talks/1/comments')
    end
  end

  setup do
    @talk = talks(:talk1)
    @user = users(:komagata)
    post user_sessions_path, params: { user: { login: @user.login_name, password: 'testtest' } }
    16.times do |index|
      @talk.comments.create!(user: @user, description: "相談コメント#{index}", created_at: index.minutes.ago)
    end
  end

  test 'show renders only the latest eight comments' do
    get talk_path(@talk)

    assert_response :success
    assert_select '.thread-comment.comment', count: 8
    assert_select '.thread-comments-more', text: %r{前のコメント（ 8 / 9 ）}
  end

  test 'comments renders the previous eight comments' do
    before_comment = @talk.comments.order(created_at: :desc).offset(7).first

    get api_comments_path, params: comment_params(before: before_comment.id)

    assert_response :success
    assert_select '.thread-comment.comment', count: 8
    assert_not_includes response.body, before_comment.description
    assert_equal '1', response.headers['X-Comment-Remaining']
  end

  test 'comments renders a page containing the target comment' do
    target_comment = @talk.comments.order(:created_at, :id).first

    get api_comments_path, params: comment_params(target: target_comment.id)

    assert_response :success
    assert_includes response.body, target_comment.description
  end

  test 'comments uses the id as a cursor when timestamps are equal' do
    created_at = 1.year.ago
    comments = Array.new(9) do |index|
      @talk.comments.create!(user: @user, description: "同時刻コメント#{index}", created_at:)
    end

    get api_comments_path, params: comment_params(before: comments.last.id)

    fragment = Nokogiri::HTML.fragment(response.body)
    rendered_ids = fragment.css('.thread-comment.comment').pluck('data-comment_id').map(&:to_i)
    assert_equal comments.first(8).pluck(:id), rendered_ids
  end

  test 'comments forbids access to another users talk' do
    get logout_path
    post user_sessions_path, params: { user: { login: 'kimura', password: 'testtest' } }

    get api_comments_path, params: comment_params(before: @talk.comments.last.id)

    assert_response :forbidden
  end

  test 'comments requires a cursor' do
    get api_comments_path, params: comment_params

    assert_response :bad_request
  end

  private

  def comment_params(**params)
    { commentable_type: 'Talk', commentable_id: @talk.id, **params }
  end
end
