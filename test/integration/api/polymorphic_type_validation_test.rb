# frozen_string_literal: true

require 'test_helper'

class API::PolymorphicTypeValidationTest < ActionDispatch::IntegrationTest
  INVALID_TYPES = ['User', 'Kernel', 'Object', 'UnknownResource', '', ' ', 'report', '::Report', '123', ['Report'], { name: 'Report' }, 123, false, nil].freeze
  RESOURCE_FIXTURES = {
    'Announcement' => %i[announcements announcement1],
    'CorporateTrainingInquiry' => %i[corporate_training_inquiries corporate_training_inquiry1],
    'PairWork' => %i[pair_works pair_work1],
    'Page' => %i[pages page1],
    'Inquiry' => %i[inquiries inquiry1],
    'Talk' => %i[talks talk1],
    'Movie' => %i[movies movie1],
    'RegularEvent' => %i[regular_events regular_event1],
    'Event' => %i[events event1],
    'Product' => %i[products product1],
    'Question' => %i[questions question1],
    'Report' => %i[reports report1]
  }.freeze

  setup do
    application = Doorkeeper::Application.create!(name: 'Polymorphic type validation', redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')
    token = Doorkeeper::AccessToken.create!(application:, resource_owner_id: users(:komagata).id, scopes: 'read write mentor')
    @headers = { Authorization: "Bearer #{token.token}" }
  end

  %w[bookmarks checks comments tags].each do |endpoint|
    types = endpoint == 'tags' ? INVALID_TYPES - ['User'] + ['Report'] : INVALID_TYPES
    types.each do |type|
      test "#{endpoint} index rejects supplied type #{type.inspect} before constant resolution" do
        without_type_resolution(type) do
          request_resource(:get, endpoint, type)
          assert_response :bad_request
        end
      end
    end
  end

  %w[bookmarks checks comments].each do |endpoint|
    INVALID_TYPES.each do |type|
      test "#{endpoint} create rejects type #{type.inspect} without side effects or constant resolution" do
        user_attributes = users(:kimura).attributes
        assert_no_resource_changes do
          without_type_resolution(type) do
            request_resource(:post, endpoint, type)
            assert_response :bad_request
          end
        end
        assert_equal user_attributes, users(:kimura).reload.attributes
      end
    end
  end

  %w[checks comments tags].each do |endpoint|
    test "#{endpoint} index requires a type" do
      get public_send("api_#{endpoint}_path", format: :json), headers: endpoint == 'tags' ? {} : @headers
      assert_response :bad_request
    end
  end

  %w[bookmarks checks comments].each do |endpoint|
    test "#{endpoint} create requires a type" do
      assert_no_resource_changes do
        post public_send("api_#{endpoint}_path", format: :json),
             params: { comment: { description: 'Must not be created' } }, headers: @headers, as: :json
        assert_response :bad_request
      end
    end

    test "#{endpoint} does not look up unsupported user records" do
      victim = users(:kimura)
      original_find = User.method(:find)
      original_find_by = User.method(:find_by)
      guarded_find = lambda do |*ids|
        assert_not_includes ids.map(&:to_s), victim.id.to_s
        original_find.call(*ids)
      end
      guarded_find_by = lambda do |**conditions|
        assert_not_equal victim.id.to_s, conditions[:id].to_s
        original_find_by.call(**conditions)
      end

      User.stub(:find, guarded_find) do
        User.stub(:find_by, guarded_find_by) do
          request_resource(:get, endpoint, 'User')
          assert_response :bad_request
          request_resource(:post, endpoint, 'User')
          assert_response :bad_request
        end
      end
    end
  end

  test 'bookmark listing without a type keeps pagination and user filtering' do
    get api_bookmarks_path(format: :json), params: { per: 2 }, headers: @headers
    assert_response :ok
    assert_equal 2, response.parsed_body['bookmarks'].size
    assert response.parsed_body['totalPages'].positive?
    assert_equal users(:komagata).bookmarks.count, response.parsed_body['unpagedBookmarks'].size
  end

  test 'bookmark listing with only an id remains unfiltered' do
    get api_bookmarks_path(format: :json), params: { bookmarkable_id: reports(:report1).id }, headers: @headers
    assert_response :ok
    assert_equal users(:komagata).bookmarks.count, response.parsed_body['unpagedBookmarks'].size
  end

  test 'invalid bookmark type is rejected before duplicate shortcut' do
    existing = bookmarks(:bookmark1)
    assert_no_resource_changes do
      post api_bookmarks_path(format: :json),
           params: { bookmarkable_type: 'User', bookmarkable_id: existing.bookmarkable_id }, headers: @headers, as: :json
      assert_response :bad_request
    end
  end

  %w[Announcement Page Talk Movie RegularEvent Event Product Question Report].each do |type|
    test "bookmark index accepts #{type} and retains resource filtering" do
      resource = resource_for(type)
      get api_bookmarks_path(format: :json), params: { bookmarkable_type: type, bookmarkable_id: resource.id }, headers: @headers
      assert_response :ok
      expected = users(:komagata).bookmarks.where(bookmarkable: resource).pluck(:id)
      assert_equal expected.sort, response.parsed_body['bookmarks'].pluck('id').sort
    end
  end

  %w[Product Report].each do |type|
    test "check index accepts #{type} and retains resource filtering" do
      resource = resource_for(type)
      get api_checks_path(format: :json), params: { checkable_type: type, checkable_id: resource.id }, headers: @headers
      assert_response :ok
      assert_equal resource.checks.ids.sort, response.parsed_body.pluck('id').sort
    end

    test "check create still accepts unchecked #{type}" do
      resource = resource_for(type).class.left_outer_joins(:checks).where(checks: { id: nil }).order(:id).first!
      assert_difference('Check.count', 1) do
        post api_checks_path(format: :json), params: { checkable_type: type, checkable_id: resource.id }, headers: @headers
        assert_response :created
      end
      assert_equal resource, Check.find(response.parsed_body['id']).checkable
    end
  end

  %w[Announcement CorporateTrainingInquiry PairWork Page Inquiry Talk Movie RegularEvent Event Product Report].each do |type|
    test "comment index accepts #{type} and retains resource filtering" do
      resource = resource_for(type)
      get api_comments_path(format: :json), params: { commentable_type: type, commentable_id: resource.id }, headers: @headers
      assert_response :ok
      assert_equal resource.comments.count, response.parsed_body['comment_total_count']
      assert_equal resource.comments.ids.sort, response.parsed_body['comments'].pluck('id').sort
    end
  end

  %w[User Page Movie Question Article].each do |type|
    test "anonymous tag index accepts #{type}" do
      get api_tags_path(format: :json), params: { taggable_type: type }
      assert_response :ok
    end
  end

  test 'anonymous Article tag listing returns its tags' do
    article = articles(:article1)
    article.tag_list.add('polymorphic-article-tag')
    article.save!
    get api_tags_path(format: :json), params: { taggable_type: 'Article' }
    assert_response :ok
    assert_includes response.parsed_body.pluck('value'), 'polymorphic-article-tag'
  end

  test 'supported bookmark creation and duplicate behavior remain available' do
    report = reports(:report1)
    users(:komagata).bookmarks.where(bookmarkable_id: report.id).destroy_all
    params = { bookmarkable_type: 'Report', bookmarkable_id: report.id }
    assert_difference('Bookmark.count', 1) do
      post api_bookmarks_path(format: :json), params:, headers: @headers
      assert_response :created
    end
    assert_equal report, Bookmark.find(response.parsed_body['id']).bookmarkable
    assert_no_difference('Bookmark.count') do
      post api_bookmarks_path(format: :json), params:, headers: @headers
      assert_response :no_content
    end
  end

  test 'supported comment creation remains available' do
    report = reports(:report1)
    assert_difference('Comment.count', 1) do
      post api_comments_path(format: :json),
           params: { commentable_type: 'Report', commentable_id: report.id, comment: { description: 'Supported comment' } }, headers: @headers
      assert_response :created
    end
    assert_equal report, Comment.find(response.parsed_body['id']).commentable
  end

  test 'missing allowed bookmark and check records retain their index behavior' do
    get api_bookmarks_path(format: :json), params: { bookmarkable_type: 'Report', bookmarkable_id: 0 }, headers: @headers
    assert_response :ok
    assert_empty response.parsed_body['bookmarks']
    get api_checks_path(format: :json), params: { checkable_type: 'Report', checkable_id: 0 }, headers: @headers
    assert_response :ok
    assert_empty response.parsed_body
  end

  test 'missing allowed comment record retains not found behavior' do
    get api_comments_path(format: :json), params: { commentable_type: 'Report', commentable_id: 0 }, headers: @headers
    assert_response :not_found
  end

  private

  def resource_for(type)
    fixture_method, name = RESOURCE_FIXTURES.fetch(type)
    public_send(fixture_method, name)
  end

  def request_resource(method, endpoint, type)
    prefix = { 'bookmarks' => 'bookmarkable', 'checks' => 'checkable', 'comments' => 'commentable', 'tags' => 'taggable' }.fetch(endpoint)
    params = { "#{prefix}_type" => type, "#{prefix}_id" => users(:kimura).id, comment: { description: 'Must not be created' } }
    public_send(method, public_send("api_#{endpoint}_path", format: :json), params:, headers: endpoint == 'tags' ? {} : @headers, as: :json)
  end

  def without_type_resolution(type, &block)
    original = ActiveSupport::Inflector.method(:constantize)
    guarded = lambda do |name|
      resource_resolution = caller_locations.any? do |location|
        location.path.match?(%r{(?:\A|/)app/controllers/api/(?:bookmarks|checks|comments|tags)_controller\.rb\z}) &&
          %w[bookmarkable checkable commentable taggable_type].include?(location.base_label)
      end
      assert_not_equal type, name, 'Unsupported request type must not be constantized' if type != 'User' || resource_resolution
      original.call(name)
    end
    ActiveSupport::Inflector.stub(:constantize, guarded, &block)
  end

  def assert_no_resource_changes(&block)
    events = []
    subscriber = ->(*args) { events << args.first }
    counts = ['Bookmark.count', 'Check.count', 'Comment.count', 'Watch.count', 'Notification.count', 'ActiveJob::Base.queue_adapter.enqueued_jobs.size']
    ActiveSupport::Notifications.subscribed(subscriber, /\A(?:check\.|came\.comment|came_comment_in_talk)/) do
      assert_no_difference(counts, &block)
    end
    assert_empty events
  end
end
