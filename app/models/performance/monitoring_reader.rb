# frozen_string_literal: true

module Performance
  class MonitoringReader
    def initialize(config: Configuration.new, transport: MonitoringTransport.new, state: nil)
      @config = config
      @transport = transport
      @state = state
    end

    def read(window:)
      @deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 12
      failure = nil
      MetricSpecs::SPECS.to_h do |metric, spec|
        result = failure ? { state: failure, groups: {} } : read_metric(metric, spec, window)
        failure = result[:state] if %i[timeout credential_error permission_error unavailable].include?(result[:state])
        [metric, result]
      end
    end

    private

    def read_metric(metric, spec, window)
      series = pages(metric, spec, window)
      return { state: :partial, groups: {} } unless series
      return descriptor(metric, spec) if series.empty?

      remaining = @deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
      raise MonitoringTransport::Error, :timeout unless remaining.positive?

      Timeout.timeout(remaining) { MetricPopulation.new(metric, window).parse(series) }
    rescue Timeout::Error
      { state: :timeout, groups: {} }
    rescue MonitoringTransport::Error => e
      { state: e.state, groups: {} }
    end

    def pages(metric, spec, window)
      series = []
      token = nil
      2.times do
        params = query(metric, spec, window)
        params << ['pageToken', token] if token
        body = @transport.get("/v3/projects/#{@config.project}/timeSeries", params)
        return if incomplete?(body)

        series.concat(body.fetch('timeSeries', []))
        return if series.sum { |item| item.fetch('points', []).length } > 10_000 || series.length > 250

        token = body['nextPageToken']
        return series if token.blank?
      end
      nil
    rescue KeyError, TypeError, NoMethodError
      nil
    end

    def incomplete?(body)
      body['executionErrors'].present? || body['unreachable'].present?
    end

    def query(metric, spec, window)
      filter = ["metric.type = \"logging.googleapis.com/user/#{spec[:name]}\"", 'resource.type = "cloud_run_revision"',
                "resource.labels.project_id = \"#{@config.project}\"", "resource.labels.service_name = \"#{@config.service}\"",
                "resource.labels.location = \"#{@config.region}\""].join(' AND ')
      [['filter', filter], ['interval.startTime', window[:start].utc.iso8601], ['interval.endTime', window[:end].utc.iso8601],
       ['aggregation.alignmentPeriod', '3600s'], ['aggregation.perSeriesAligner', 'ALIGN_SUM'], ['aggregation.crossSeriesReducer', 'REDUCE_SUM'],
       ['view', 'FULL'], ['pageSize', '10000']] + MetricSpecs.labels(metric).map { |label| ['aggregation.groupByFields', "metric.labels.#{label}"] }
    end

    def descriptor(metric, spec)
      key = "descriptor:#{@config.identity}:#{spec[:name]}"
      return { state: :ready, groups: {} } if @state&.read(key)

      path = "/v3/projects/#{@config.project}/metricDescriptors/logging.googleapis.com/user/#{spec[:name]}"
      body = @transport.get(path, [])
      return { state: :invalid_schema, groups: {} } unless valid_descriptor?(body, metric, spec)

      @state&.write(key, true, expires_in: 1.hour)
      { state: :ready, groups: {} }
    rescue KeyError, TypeError, NoMethodError
      { state: :invalid_schema, groups: {} }
    end

    def valid_descriptor?(body, metric, spec)
      fields = body.fetch('labels', []).map { |label| label.fetch('key') }
      body.values_at('metricKind', 'valueType', 'unit') == ['DELTA', metric == 'coverage' ? 'INT64' : 'DISTRIBUTION', spec[:unit]] &&
        fields.sort == MetricSpecs.labels(metric).sort && body.fetch('labels', []).all? { |label| label['valueType'] == 'STRING' }
    end
  end
end
