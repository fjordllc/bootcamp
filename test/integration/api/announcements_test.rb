# frozen_string_literal: true

require 'test_helper'

class API::AnnouncementsTest < ActionDispatch::IntegrationTest
  setup { travel_to Time.zone.local(2026, 11, 7, 12) }
  teardown { travel_back }

  test 'paginates with a bounded page size and rejects malformed pagination' do
    sign_in(:kimura)
    Announcement.update_all(wip: false, published_at: Time.zone.local(2026, 1, 1)) # rubocop:disable Rails/SkipsModelValidations
    expected_ids = Announcement.order(id: :desc).pluck(:id)

    get '/api/announcements', params: { page: '2', per_page: '2' }
    assert_response :ok
    assert_equal expected_ids.slice(2, 2), response.parsed_body.fetch('announcements').pluck('id')
    assert_equal (expected_ids.size / 2.0).ceil, response.parsed_body.fetch('total_pages')

    get '/api/announcements', params: { page: '1000000', per_page: '100' }
    assert_response :ok
    assert_empty response.parsed_body.fetch('announcements')

    %w[0 -1 1.0 NaN 01 1000001].concat(['9' * 1000, '', ['1'], { number: '1' }]).each do |page|
      get '/api/announcements', params: { page: }
      assert_response :bad_request, page.inspect
    end
    [0, -1, 101, '1x', '', ['20'], { size: '20' }].each do |per_page|
      get '/api/announcements', params: { per_page: }
      assert_response :bad_request, per_page.inspect
    end
  end

  test 'uses twenty items by default and accepts one hundred items' do
    sign_in(:kimura)
    Announcement.update_all(wip: true) # rubocop:disable Rails/SkipsModelValidations
    105.times do |index|
      Announcement.create!(user: users(:kimura), title: "お知らせ#{index}", description: '**本文**', target: :all, published_at: 1.day.ago)
    end
    get '/api/announcements'
    assert_equal 20, response.parsed_body.fetch('announcements').size
    get '/api/announcements', params: { per_page: '100' }
    assert_equal 100, response.parsed_body.fetch('announcements').size
  end

  test 'lists published announcements in stable publication order without personal data or footprints' do
    travel_to Time.zone.local(2026, 11, 7, 12) do
      sign_in(:kimura)
      Announcement.update_all(wip: true) # rubocop:disable Rails/SkipsModelValidations
      first = announcements(:announcement1)
      second = announcements(:announcement2)
      first.update!(wip: false, published_at: Time.current, target: :students)
      second.update!(wip: false, published_at: Time.current, target: :job_seekers)
      older = announcements(:announcement5)
      older.update!(wip: false, published_at: 1.second.ago)
      announcements(:announcement3).update!(wip: false, published_at: nil)
      announcements(:announcement4).update!(wip: false, published_at: 1.second.from_now)

      assert_no_difference('Footprint.count') { get '/api/announcements.json' }

      assert_response :ok
      items = response.parsed_body.fetch('announcements')
      assert_equal [first.id, second.id].sort.reverse + [older.id], items.pluck('id')
      assert_equal %w[job_seekers students].sort, items.first(2).pluck('target').sort
      assert_equal %w[description id published_at target title url], items.first.keys.sort
      assert_equal first.description, items.find { |item| item['id'] == first.id }.fetch('description')
      assert_equal announcement_path(items.first.fetch('id')), items.first.fetch('url')
      assert_equal Time.current.iso8601, items.first.fetch('published_at')
      assert_equal 1, response.parsed_body.fetch('total_pages')
    end
  end
end
