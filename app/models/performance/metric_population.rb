# frozen_string_literal: true

module Performance
  class MetricPopulation
    def initialize(metric, window)
      @metric = metric
      @spec = MetricSpecs::SPECS.fetch(metric)
      @window = window
      @intervals = Hash.new { |hash, key| hash[key] = [] }
    end

    def parse(series)
      groups = {}
      series.each { |item| merge_series(groups, item) }
      { state: :ready, groups: }
    rescue ArgumentError, KeyError, TypeError, NoMethodError
      { state: :invalid_schema, groups: {} }
    end

    private

    def merge_series(groups, item)
      raise ArgumentError unless item.values_at('metricKind', 'valueType', 'unit') == ['DELTA', @metric == 'coverage' ? 'INT64' : 'DISTRIBUTION', @spec[:unit]]

      labels = item.fetch('metric').fetch('labels')
      key = group_key(labels)
      item.fetch('points').each do |point|
        validate_interval(key, point.fetch('interval'))
        value = point.fetch('value')
        observation = if @metric == 'coverage'
                        Histogram.integer(value.fetch('int64Value'))
                      else
                        Histogram.from_google(value.fetch('distributionValue'),
                                              bounds: @spec[:bounds])
                      end
        groups[key] = groups.key?(key) ? combine(groups[key], observation) : observation
      end
    end

    def group_key(labels)
      fields = MetricSpecs.labels(@metric)
      raise ArgumentError unless labels.keys.sort == fields.sort && Pages::REGISTRY.key?(labels['page'])
      raise ArgumentError if fields.include?('device') && !Pages::DEVICES.include?(labels['device'])

      validate_coverage_labels(labels) if @metric == 'coverage'

      fields.map { |field| labels.fetch(field) }
    end

    def validate_coverage_labels(labels)
      raise ArgumentError unless Pages::METRICS.include?(labels['metric']) && Pages::STATES.include?(labels['state'])
    end

    def validate_interval(key, interval)
      start_at = Time.iso8601(interval.fetch('startTime'))
      end_at = Time.iso8601(interval.fetch('endTime'))
      validate_hour(start_at, end_at)
      raise ArgumentError if @intervals[key].any? { |left, right| start_at < right && end_at > left }

      @intervals[key] << [start_at, end_at]
    end

    def validate_hour(start_at, end_at)
      raise ArgumentError unless start_at >= @window[:start] && end_at <= @window[:end] && end_at - start_at == 3600
      raise ArgumentError unless (start_at.to_r % 3600).zero? && (end_at.to_r % 3600).zero?
    end

    def combine(left, right)
      @metric == 'coverage' ? left + right : left.merge(right)
    end
  end
end
