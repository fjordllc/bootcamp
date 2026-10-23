# frozen_string_literal: true

require 'test_helper'

class Performance::HistogramTest < ActiveSupport::TestCase
  test 'merges populations instead of averaging revision percentiles' do
    fast = Performance::Histogram.new(bounds: [0, 100, 500, 1000], counts: [0, 99, 0, 0, 0])
    slow = Performance::Histogram.new(bounds: [0, 100, 500, 1000], counts: [0, 0, 0, 0, 1])
    assert_equal [0, 100], fast.merge(slow).quantile(0.95)
    assert_equal 100, fast.merge(slow).count
  end

  test 'does not fabricate a quantile from empty observations' do
    histogram = Performance::Histogram.new(bounds: [0, 100], counts: [0, 0, 0])
    assert_nil histogram.quantile(0.75)
  end

  test 'rejects incompatible schemas and invalid negative populations' do
    histogram = Performance::Histogram.new(bounds: [0, 100], counts: [0, 20, 0])
    assert_raises(ArgumentError) { histogram.merge(Performance::Histogram.new(bounds: [0, 200], counts: [0, 20, 0])) }
    assert_raises(ArgumentError) { Performance::Histogram.new(bounds: [0, 100], counts: [1, 20, 0]) }
  end
end

class Performance::GoogleHistogramTest < ActiveSupport::TestCase
  test 'Google count strings stay integers with omitted trailing zero buckets and overflow' do
    body = { 'count' => '20', 'bucketCounts' => %w[0 20], 'bucketOptions' => { 'explicitBuckets' => { 'bounds' => [0, 100, 200] } } }
    histogram = Performance::Histogram.from_google(body, bounds: [0, 100, 200])
    assert_equal [0, 20, 0, 0], histogram.counts
    assert_equal [0, 100], histogram.quantile(0.75)
    overflow = Performance::Histogram.new(bounds: [0, 100, 200], counts: [0, 0, 0, 20])
    assert_equal [200, nil], overflow.quantile(0.75)
    assert_equal 9_223_372_036_854_775_807, Performance::Histogram.integer('9223372036854775807')
  end

  test 'count mismatch noninteger counts schema mismatch and invalid ranks are rejected' do
    body = { 'count' => '21', 'bucketCounts' => %w[0 20], 'bucketOptions' => { 'explicitBuckets' => { 'bounds' => [0, 100] } } }
    assert_raises(ArgumentError) { Performance::Histogram.from_google(body, bounds: [0, 100]) }
    assert_raises(ArgumentError) { Performance::Histogram.from_google(body, bounds: [0, 200]) }
    ['1.1', '-1', 'Infinity', '9223372036854775808', 20].each do |count|
      assert_raises(ArgumentError) { Performance::Histogram.integer(count) }
    end
    histogram = Performance::Histogram.new(bounds: [0, 100], counts: [0, 20])
    assert_raises(ArgumentError) { histogram.quantile(0) }
  end
end
