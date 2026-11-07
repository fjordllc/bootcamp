# frozen_string_literal: true

require 'test_helper'

class API::EventsTest < ActionDispatch::IntegrationTest
  setup do
    travel_to Time.zone.local(2026, 11, 7, 12)
    sign_in(:kimura)
    Event.update_all(wip: true) # rubocop:disable Rails/SkipsModelValidations
    RegularEvent.update_all(finished: true) # rubocop:disable Rails/SkipsModelValidations
    @special = events(:event1)
    @regular = regular_events(:regular_event1)
  end

  teardown { travel_back }

  test 'merges special and regular occurrences including ongoing events in Tokyo time without footprints' do
    @special.update!(wip: false, start_at: Time.current - 1.hour, end_at: Time.current + 1.hour)
    prepare_regular

    assert_no_difference('Footprint.count') { get '/api/events.json' }

    assert_response :ok
    items = response.parsed_body.fetch('events')
    assert_equal %w[event regular_event], items.pluck('kind')
    assert_equal [@special.id, @regular.id], items.pluck('id')
    assert_equal %w[end_at held id kind start_at title url], items.first.keys.sort
    assert_equal '2026-11-07T11:00:00+09:00', items.first.fetch('start_at')
    assert_equal '2026-11-07T13:00:00+09:00', items.first.fetch('end_at')
    assert_equal '2026-11-07T15:00:00+09:00', items.last.fetch('start_at')
    assert_equal '2026-11-07T16:00:00+09:00', items.last.fetch('end_at')
    assert_equal [true, true], items.pluck('held')
    assert_equal [event_path(@special), regular_event_path(@regular)], items.pluck('url')
    assert_equal 1, response.parsed_body.fetch('total_pages')
  end

  test 'accepts an inclusive date range of at most thirty one days and rejects malformed input' do
    prepare_regular
    get '/api/events', params: { from: '2026-11-07', to: '2026-12-07' }
    assert_response :ok
    assert_equal(%w[2026-11-07 2026-11-14 2026-11-21 2026-11-28 2026-12-05],
                 response.parsed_body.fetch('events').map { |event| event.fetch('start_at')[0, 10] })

    [
      { from: '2026-11-07', to: '2026-12-08' },
      { from: '2026-11-08', to: '2026-11-07' },
      { from: '2026-02-30' }, { from: '2026-11-7' }, { from: '2026-11-07T00:00:00Z' },
      { from: '999999999999-01-01' }, { from: '0000-01-01' }, { from: '' },
      { from: ['2026-11-07'] }, { to: { date: '2026-11-07' } }
    ].each do |params|
      get '/api/events', params: params
      assert_response :bad_request, params.inspect
    end
    get '/api/events', params: { from: '2026-11-14' }
    assert_response :ok
    assert_equal ['2026-11-14T15:00:00+09:00'], response.parsed_body.fetch('events').pluck('start_at')
  end

  test 'paginates occurrences in a stable order and bounds the response size' do
    prepare_regular
    @special.update!(wip: false, start_at: Time.zone.local(2026, 11, 7, 15), end_at: Time.zone.local(2026, 11, 7, 16))
    get '/api/events', params: { per_page: '1' }
    assert_response :ok
    assert_equal [@special.id], response.parsed_body.fetch('events').pluck('id')
    assert_equal 2, response.parsed_body.fetch('total_pages')
    get '/api/events', params: { per_page: '1', page: '2' }
    assert_equal [@regular.id], response.parsed_body.fetch('events').pluck('id')
    get '/api/events', params: { page: '3', per_page: '1' }
    assert_empty response.parsed_body.fetch('events')
    [{ page: ['1'] }, { page: '0' }, { page: '1000001' }, { per_page: '101' }, { per_page: { value: '1' } }].each do |params|
      get '/api/events', params: params
      assert_response :bad_request
    end
  end

  test 'includes ongoing special events that started before the requested day and excludes the end boundary' do
    @special.update!(wip: false, start_at: Time.zone.local(2026, 11, 6, 23), end_at: Time.current + 1.second)
    get '/api/events', params: { from: '2026-11-07', to: '2026-11-07' }
    assert_equal [@special.id], response.parsed_body.fetch('events').pluck('id')
    @special.update!(end_at: Time.current)
    get '/api/events'
    assert_empty response.parsed_body.fetch('events')
  end

  test 'reuses monthly and ISO odd even recurrence rules without duplicate occurrences' do
    {
      1 => %w[2026-11-07 2026-12-05], 2 => %w[2026-11-14],
      3 => %w[2026-11-21], 4 => %w[2026-11-28],
      5 => %w[2026-11-07 2026-11-21 2026-12-05], 6 => %w[2026-11-14 2026-11-28]
    }.each do |frequency, expected_dates|
      prepare_regular(frequency:)
      @regular.regular_event_repeat_rules.create!(frequency:, day_of_the_week: 6)
      get '/api/events', params: { from: '2026-11-07', to: '2026-12-07' }
      assert_response :ok
      assert_equal(expected_dates, response.parsed_body.fetch('events').map { |event| event.fetch('start_at')[0, 10] })
    end
  end

  test 'marks holidays and individual skip dates as not held rather than removing them' do
    prepare_regular(day: 1)
    get '/api/events', params: { from: '2026-11-23', to: '2026-11-23' }
    assert_equal [false], response.parsed_body.fetch('events').pluck('held')
    @regular.update!(hold_national_holiday: true)
    get '/api/events', params: { from: '2026-11-23', to: '2026-11-23' }
    assert_equal [true], response.parsed_body.fetch('events').pluck('held')
    @regular.regular_event_skip_dates.create!(skip_on: Date.new(2026, 11, 23))
    get '/api/events', params: { from: '2026-11-23', to: '2026-11-23' }
    assert_equal [false], response.parsed_body.fetch('events').pluck('held')
  end

  test 'excludes WIP and finished regular events and excludes occurrences ending exactly now' do
    prepare_regular
    @regular.update!(wip: true)
    get '/api/events'
    assert_empty response.parsed_body.fetch('events')
    @regular.update!(wip: false, finished: true)
    get '/api/events'
    assert_empty response.parsed_body.fetch('events')
    @regular.update!(finished: false)
    travel_to Time.zone.local(2026, 11, 7, 15, 59, 59)
    get '/api/events'
    assert_equal [@regular.id], response.parsed_body.fetch('events').pluck('id')
    travel_to Time.zone.local(2026, 11, 7, 16)
    get '/api/events'
    assert_empty response.parsed_body.fetch('events')
  end

  test 'uses Tokyo day boundaries and excludes the next midnight' do
    @special.update!(wip: false, start_at: Time.iso8601('2026-11-07T15:00:00Z'), end_at: Time.iso8601('2026-11-07T16:00:00Z'))
    get '/api/events', params: { from: '2026-11-07', to: '2026-11-07' }
    assert_empty response.parsed_body.fetch('events')
    get '/api/events', params: { from: '2026-11-08', to: '2026-11-08' }
    assert_equal ['2026-11-08T00:00:00+09:00'], response.parsed_body.fetch('events').pluck('start_at')
    @special.update!(end_at: Time.zone.local(2026, 11, 9))
    get '/api/events', params: { from: '2026-11-09', to: '2026-11-09' }
    assert_empty response.parsed_body.fetch('events')
  end

  test 'caps each page at one hundred and sorts same-kind ties by original id' do
    105.times do
      event = @special.dup
      event.assign_attributes(wip: false, start_at: Time.current + 1.hour, end_at: Time.current + 2.hours)
      event.save!
    end
    expected_ids = Event.where(wip: false).order(:id).pluck(:id)
    get '/api/events'
    assert_equal expected_ids.first(20), response.parsed_body.fetch('events').pluck('id')
    get '/api/events', params: { per_page: '100' }
    assert_equal expected_ids.first(100), response.parsed_body.fetch('events').pluck('id')
    get '/api/events', params: { per_page: '100', page: '2' }
    assert_equal expected_ids.drop(100), response.parsed_body.fetch('events').pluck('id')
  end

  private

  def prepare_regular(frequency: 0, day: 6)
    @regular.update!(finished: false, wip: false, hold_national_holiday: false)
    @regular.regular_event_repeat_rules.delete_all
    @regular.regular_event_repeat_rules.create!(frequency:, day_of_the_week: day)
  end
end
