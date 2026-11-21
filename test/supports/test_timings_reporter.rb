# frozen_string_literal: true

require 'json'
require 'fileutils'

# テストごとの所要時間と再試行をJSONに書き出す。TEST_TIMINGS_PATH を指定したときだけ使う。
# 出力は bin/ci-test-timings merge でまとめる。
class TestTimingsReporter < Minitest::AbstractReporter
  def initialize(path, root: Dir.pwd, shard: ENV.fetch('TEST_SHARD', nil))
    super()
    @path = path
    @root = "#{File.expand_path(root)}/"
    @shard = shard
    @tests = []
    @retries = Hash.new { |hash, key| hash[key] = { count: 0, time: 0.0 } }
  end

  # 再試行の直前に、失敗した実行の時間を控える。record に渡るのは最後の実行だけのため。
  def record_retry(class_name, name, failed_result)
    retries = @retries[[class_name.to_s, name.to_s]]
    retries[:count] += 1
    retries[:time] += failed_result.time
  end

  def record(result)
    retries = @retries.fetch([result.klass.to_s, result.name.to_s], { count: 0, time: 0.0 })
    @tests << {
      file: file_of(result), class: result.klass.to_s, name: result.name.to_s, time: result.time.round(3),
      retries: retries[:count], retry_time: retries[:time].round(3)
    }
  end

  def report
    FileUtils.mkdir_p(File.dirname(@path))
    File.write(@path, JSON.generate(shard: @shard, tests: @tests))
  end

  private

  # 共有モジュールで定義したテストも、テストクラスのあるファイルに数える。
  def file_of(result)
    path = Object.const_source_location(result.klass.to_s)&.first || result.source_location.first
    path.delete_prefix(@root)
  end
end

module Minitest
  def self.plugin_test_timings_init(_options)
    path = ENV.fetch('TEST_TIMINGS_PATH', nil)
    return if path.blank?

    timings_reporter = TestTimingsReporter.new(path)
    reporter << timings_reporter
    return unless Minitest::Retry.retry_count

    Minitest::Retry.on_retry { |klass, name, _count, result| timings_reporter.record_retry(klass.name, name, result) }
  end
end

Minitest.extensions << 'test_timings' unless Minitest.extensions.include?('test_timings')
