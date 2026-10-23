# frozen_string_literal: true

module Performance
  class Snapshot
    attr_reader :state, :window, :fetched_at, :valid_until, :collection_started_at, :pages, :summary, :limited

    def self.fetch(now: Time.current, config: Configuration.new, shared: nil, reader: nil)
      return new(state: :unconfigured, now:, config:) unless config.configured?
      return new(state: :paused, now:, config:) unless config.collection?

      shared ||= SharedState.new
      key = "snapshot:#{config.identity}"
      cached = current_snapshot(shared, key, now, config.started_at)
      return cached if cached

      result = shared.synchronize(2) do
        cached = current_snapshot(shared, key, now, config.started_at)
        next cached if cached

        # Confirm shared writes before spending API budget. If the final write
        # fails, this neutral reservation still prevents a refresh stampede.
        shared.write(key, new(state: :refreshing, now:, config:), expires_in: 5.minutes)
        snapshot = build_snapshot(reader, shared, config, now)
        shared.write(key, snapshot, expires_in: 10.minutes)
        snapshot
      end
      result == :busy ? new(state: :refreshing, now:, config:) : result
    rescue SharedState::Unavailable
      new(state: :unavailable, now:, config:)
    end

    def self.build_snapshot(reader, shared, config, now)
      reader ||= MonitoringReader.new(config:, state: shared)
      snapshot = new(state: :ready, now:, config:)
      snapshot.populate(reader.read(window: snapshot.window), limited_at: shared.read('limited_at'))
    end
    private_class_method :build_snapshot

    def self.current_snapshot(shared, key, now, started_at)
      snapshot = shared.read(key)
      snapshot if snapshot && snapshot.valid_until > now && snapshot.collection_started_at == started_at
    end
    private_class_method :current_snapshot

    def initialize(state:, now:, config: Configuration.new)
      @state = state
      end_at = Time.at(((now.to_i - 15.minutes) / 3600) * 3600).utc
      @window = { start: end_at - 24.hours, end: end_at }
      @fetched_at = state == :ready ? now : nil
      @valid_until = now + 5.minutes
      @collection_started_at = config.started_at
      populate({})
    end

    def populate(results, limited_at: nil)
      @state = :ready if fetched_at && results.any?
      @limited = limited_during_window?(limited_at)
      @pages = Pages::REGISTRY.map { |key, values| page_result(results, key, values.last) }
      @pages.sort_by! { |page| page[:summary].sort_order }
      @summary = Summary.new(@pages.flat_map { |page| page_cells(page) }, complete: complete_period?)
      @state = :partial if state == :ready && partial?
      self
    end

    def label
      { unconfigured: '設定が必要です', paused: '計測を停止しています', unavailable: 'データを取得できません', refreshing: '集計を更新中です',
        partial: '一部のデータは判定待ちです', ready: '集計済み' }.fetch(state)
    end

    private

    def limited_during_window?(range)
      range.present? && range['last'] >= window[:start].to_i && range['first'] <= window[:end].to_i
    end

    def partial?
      !complete_period? || @summary.unknown_count.positive?
    end

    def page_result(results, key, label)
      server = metric_cell(results, 'server', [key])
      browser = Pages::DEVICES.index_with do |device|
        Pages::METRICS.index_with { |metric| metric_cell(results, metric, [key, device]) }
      end
      page = { key:, label:, server:, browser: }
      page.merge(summary: Summary.new(page_cells(page), complete: complete_period?))
    end

    def page_cells(page)
      [page[:server]] + page[:browser].values.flat_map(&:values)
    end

    def complete_period?
      collection_started_at && collection_started_at <= window[:start] && !limited
    end

    def metric_cell(results, metric, key)
      result = results[metric]
      return Cell.new(metric:, state: state == :ready ? :no_data : state) unless result
      return Cell.new(metric:, state: result[:state]) unless result[:state] == :ready

      histogram = result[:groups][key]
      received = coverage(results, metric, key)
      cell_state = browser_state(results, metric, received, histogram)
      Cell.new(metric:, count: histogram&.count || 0, interval: histogram&.quantile(metric == 'server' ? 0.95 : 0.75), state: cell_state, received:)
    end

    def coverage(results, metric, key)
      return if metric == 'server' || results.dig('coverage', :state) != :ready

      groups = results.fetch('coverage').fetch(:groups)
      Pages::STATES.index_with { |availability| groups.fetch(key + [metric, availability], 0) }
    end

    def browser_state(results, metric, received, histogram)
      return if metric == 'server'
      return results.dig('coverage', :state) || :partial unless received

      count = histogram&.count || 0
      return :partial unless received['observed'] == count
      return if count.positive?

      availability_state(received)
    end

    def availability_state(received)
      return :unsupported if received['unsupported'].positive? && received['unobserved'].zero?
      return :unobserved if received['unobserved'].positive?

      nil
    end
  end
end
