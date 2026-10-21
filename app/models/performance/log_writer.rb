# frozen_string_literal: true

module Performance
  class LogWriter
    MUTEX = Mutex.new

    def initialize(output: $stdout)
      @output = output
    end

    def server(page:, duration_ms:)
      return unless Pages::REGISTRY.key?(page) && duration_ms.is_a?(Numeric) && duration_ms.finite? && duration_ms >= 0

      write([{ kind: 'server', page:, duration_ms: }])
    end

    def browser(page:, device:, metrics:)
      report = Report.new('performance_report' => { 'token' => 'internal', 'page' => page, 'device' => device, 'metrics' => metrics })
      return unless report.valid?

      records = Pages::METRICS.map do |metric|
        observation = metrics.fetch(metric)
        record = { kind: 'browser', page:, device:, metric:, state: observation.fetch('state') }
        record[:value] = observation.fetch('value') if observation['state'] == 'observed'
        record
      end
      write(records)
    end

    def notification(event)
      payload = event.payload
      return unless payload[:performance_eligible] && payload[:method] == 'GET' && payload[:format].to_s == 'html'
      return unless payload[:status].to_i.between?(200, 299) && !payload[:exception] && !payload[:exception_object]

      server(page: payload[:performance_page], duration_ms: event.duration)
    end

    def self.install
      previous = Rails.application.config.x.performance_subscription
      ActiveSupport::Notifications.unsubscribe(previous) if previous
      Rails.application.config.x.performance_subscription = ActiveSupport::Notifications.monotonic_subscribe('process_action.action_controller') do |*args|
        next unless Configuration.new.collection?

        new.notification(ActiveSupport::Notifications::Event.new(*args))
      end
    end

    private

    def write(records)
      data = records.map { |record| "#{JSON.generate({ severity: 'INFO', event: 'bootcamp_performance', schema: 1 }.merge(record))}\n" }.join
      MUTEX.synchronize { @output.write(data) }
      true
    rescue IOError, SystemCallError
      warn_once
      false
    end

    def warn_once
      MUTEX.synchronize do
        now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        warned_at = self.class.instance_variable_get(:@warned_at)
        return if warned_at && now - warned_at < 60

        self.class.instance_variable_set(:@warned_at, now)
        Rails.logger.warn('Performance output unavailable')
      end
    rescue IOError, SystemCallError
      nil
    end
  end
end
