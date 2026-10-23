# frozen_string_literal: true

module Performance
  class Histogram
    attr_reader :bounds, :counts, :count

    def initialize(bounds:, counts:)
      raise ArgumentError unless bounds.is_a?(Array) && counts.is_a?(Array)
      raise ArgumentError unless valid_bounds?(bounds) && valid_counts?(bounds, counts)

      @bounds = bounds.freeze
      @counts = (counts + Array.new(bounds.length + 1 - counts.length, 0)).freeze
      raise ArgumentError unless @counts.first.zero?

      @count = @counts.sum
    end

    def self.from_google(value, bounds:)
      raise ArgumentError unless value.is_a?(Hash) && value.dig('bucketOptions', 'explicitBuckets', 'bounds') == bounds

      histogram = new(bounds:, counts: value.fetch('bucketCounts', []).map { |count| integer(count) })
      raise ArgumentError unless integer(value.fetch('count')) == histogram.count

      histogram
    end

    def self.integer(value)
      raise ArgumentError unless value.is_a?(String) && value.match?(/\A(?:0|[1-9][0-9]{0,18})\z/)

      result = Integer(value, 10)
      raise ArgumentError if result > 9_223_372_036_854_775_807

      result
    end

    def merge(other)
      raise ArgumentError unless bounds == other.bounds

      self.class.new(bounds:, counts: counts.zip(other.counts).map { |left, right| left + right })
    end

    def quantile(fraction)
      return if count.zero?
      raise ArgumentError unless fraction.positive? && fraction <= 1

      rank = (BigDecimal(fraction.to_s) * count).ceil
      cumulative = 0
      index = counts.index do |value|
        cumulative += value
        cumulative >= rank
      end
      [bounds[index - 1], bounds[index]]
    end

    private

    def valid_bounds?(bounds)
      bounds.first&.zero? && bounds.all? { |bound| bound.is_a?(Numeric) && bound.finite? } &&
        bounds.each_cons(2).all? { |left, right| left < right }
    end

    def valid_counts?(bounds, counts)
      counts.length <= bounds.length + 1 && counts.all? { |count| count.is_a?(Integer) && count >= 0 }
    end
  end
end
