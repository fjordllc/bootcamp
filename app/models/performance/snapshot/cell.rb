# frozen_string_literal: true

module Performance
  class Snapshot
    class Cell
      attr_reader :state, :rating, :sample_count, :percentile, :lower, :upper, :unit, :received

      def initialize(metric:, count: 0, interval: nil, state: nil, received: nil)
        @sample_count = count
        @lower, @upper = interval
        @unit = MetricSpecs::SPECS.fetch(metric).fetch(:unit)
        @percentile = metric == 'server' ? 95 : 75
        @received = received
        @state = state || (count.zero? ? :no_data : :insufficient)
        return if state || count < 20 || interval.nil?

        @rating = classify(MetricSpecs::SPECS.fetch(metric).fetch(:goals))
        @state = @rating ? :measured : :boundary
      end

      def label
        return { good: '良好', attention: '要注意', poor: '要改善' }.fetch(rating) if rating

        { no_data: 'まだ計測データがありません', insufficient: "サンプルが不足しています（#{sample_count} / 20件）",
          unsupported: 'このブラウザーでは計測できません', unobserved: 'まだ値を受信していません', boundary: '判定待ち（境界付近）',
          unconfigured: '設定が必要です', paused: '計測を停止しています', partial: '一部のデータを取得できません', partial_period: '計測開始から24時間未満です',
          missing_metric: '計測設定を確認してください', refreshing: '集計を更新中です' }.fetch(state, 'データを取得できません')
      end

      def range
        return '—' unless lower

        if unit == 'ms'
          upper ? "#{format('%.2f', lower / 1000.0)}–#{format('%.2f', upper / 1000.0)} 秒" : "#{format('%.2f', lower / 1000.0)} 秒以上"
        else
          upper ? "#{lower}–#{upper}" : "#{lower} 以上"
        end
      end

      private

      def classify(goals)
        good, poor = goals
        return :good if upper && upper <= good
        return :attention if lower > good && upper && upper <= poor
        return :poor if lower > poor

        nil
      end
    end
  end
end
