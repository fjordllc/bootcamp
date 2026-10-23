# frozen_string_literal: true

module Performance
  class Report
    attr_reader :token, :page, :device, :metrics

    def initialize(body)
      @body = body
      report = body.is_a?(Hash) && body['performance_report']
      return unless report.is_a?(Hash)

      @token, @page, @device, @metrics = report.values_at('token', 'page', 'device', 'metrics')
    end

    def valid?
      shape_valid? && dimensions_valid? && token.is_a?(String) && token.bytesize.between?(1, 1024) &&
        metrics.all? { |name, observation| valid_metric?(name, observation) }
    end

    private

    def shape_valid?
      exact_keys?(@body, %w[performance_report]) && exact_keys?(@body['performance_report'], %w[token page device metrics]) &&
        exact_keys?(metrics, Pages::METRICS)
    end

    def dimensions_valid?
      Pages::REGISTRY.key?(page) && Pages::DEVICES.include?(device)
    end

    def exact_keys?(value, keys)
      value.is_a?(Hash) && value.keys.sort == keys.sort
    end

    def valid_metric?(name, observation)
      return false unless observation.is_a?(Hash) && Pages::STATES.include?(observation['state'])
      return exact_keys?(observation, %w[state]) unless observation['state'] == 'observed'

      exact_keys?(observation, %w[state value]) && valid_value?(name, observation['value'])
    end

    def valid_value?(name, value)
      value.is_a?(Numeric) && value.finite? && value >= 0 && value <= (name == 'CLS' ? 100 : 3_600_000)
    end
  end
end
