# frozen_string_literal: true

module Performance
  module MetricSpecs
    SPECS = {
      'server' => { name: 'bootcamp_perf_server_ms_v1', unit: 'ms',
                    bounds: [0, 50, 100, 200, 300, 400, 500, 600, 750, 1000, 1250, 1500, 2000, 3000, 5000, 10_000, 30_000, 60_000], goals: [500, 1000] },
      'LCP' => { name: 'bootcamp_perf_lcp_ms_v1', unit: 'ms',
                 bounds: [0, 100, 250, 500, 1000, 1500, 2000, 2250, 2500, 2750, 3000, 3500, 4000, 4500, 5000, 6000, 8000, 10_000, 15_000, 30_000, 60_000],
                 goals: [2500, 4000] },
      'INP' => { name: 'bootcamp_perf_inp_ms_v1', unit: 'ms',
                 bounds: [0, 16, 40, 80, 120, 160, 200, 240, 300, 400, 500, 600, 800, 1000, 1500, 3000, 10_000, 60_000], goals: [200, 500] },
      'CLS' => { name: 'bootcamp_perf_cls_v1', unit: '1', bounds: [0, 0.01, 0.025, 0.05, 0.075, 0.1, 0.125, 0.15, 0.2, 0.25, 0.3, 0.4, 0.5, 1, 2, 5, 10, 100],
                 goals: [0.1, 0.25] },
      'coverage' => { name: 'bootcamp_perf_browser_observations_v1', unit: '1' }
    }.each_value do |spec|
      spec.each_value(&:freeze)
      spec.freeze
    end.freeze

    def self.labels(metric)
      return %w[page] if metric == 'server'
      return %w[page device metric state] if metric == 'coverage'

      %w[page device]
    end

    def self.template(metric, config)
      spec = SPECS.fetch(metric)
      result = {
        name: spec[:name], description: "Bootcamp performance schema 1: #{metric}", filter: filter(metric, config),
        metricDescriptor: { metricKind: 'DELTA', valueType: metric == 'coverage' ? 'INT64' : 'DISTRIBUTION', unit: spec[:unit],
                            labels: labels(metric).map { |key| { key:, valueType: 'STRING' } } },
        labelExtractors: labels(metric).index_with { |key| "EXTRACT(jsonPayload.#{key})" }
      }
      return result if metric == 'coverage'

      result.merge(valueExtractor: "EXTRACT(jsonPayload.#{metric == 'server' ? 'duration_ms' : 'value'})",
                   bucketOptions: { explicitBuckets: { bounds: spec[:bounds] } })
    end

    def self.filter(metric, config)
      common = ['resource.type="cloud_run_revision"', "resource.labels.project_id=\"#{config.project}\"",
                "resource.labels.service_name=\"#{config.service}\"", "resource.labels.location=\"#{config.region}\"",
                "logName=\"projects/#{config.project}/logs/run.googleapis.com%2Fstdout\"",
                'jsonPayload.event="bootcamp_performance"', 'jsonPayload.schema=1', choices('page', Pages::REGISTRY.keys)]
      common.concat(metric == 'server' ? ['jsonPayload.kind="server"', 'jsonPayload.duration_ms:*'] : browser_filter(metric))
      common.join(' AND ')
    end

    def self.browser_filter(metric)
      base = ['jsonPayload.kind="browser"', choices('device', Pages::DEVICES)]
      return base + [choices('metric', Pages::METRICS), choices('state', Pages::STATES)] if metric == 'coverage'

      base + ["jsonPayload.metric=\"#{metric}\"", 'jsonPayload.state="observed"', 'jsonPayload.value:*']
    end

    def self.choices(field, values)
      "(#{values.map { |value| "jsonPayload.#{field}=\"#{value}\"" }.join(' OR ')})"
    end
    private_class_method :browser_filter, :choices
  end
end
