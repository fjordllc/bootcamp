# frozen_string_literal: true

require 'json'

# CIで記録したテストの所要時間を集計し、テストファイルをシャードへ振り分ける。
# bin/ci-test-timings からRailsなしで読み込むため、標準ライブラリだけを使う。
module CiTestTimings
  DEFAULT_SECONDS = 1.0
  MINIMUM_SECONDS = 0.1
  SUMMARY_ROWS = 20

  module_function

  # 所要時間の長いファイルから順に、その時点で合計が最も短いシャードへ入れる。
  # 記録のないファイルは、記録のあるファイルの中央値として扱う。
  def split(files, timings, shard_count)
    default = default_seconds(files, timings)
    shards = Array.new(shard_count) { { files: [], seconds: 0.0 } }
    # Railsなしで動かすため、Active Support の index_with は使わない。
    weights = files.uniq.to_h { |file| [file, [timings[file] || default, MINIMUM_SECONDS].max] } # rubocop:disable Rails/IndexWith

    weights.sort_by { |file, seconds| [-seconds, file] }.each do |file, seconds|
      shard = shards.each_with_index.min_by { |candidate, index| [candidate[:seconds], index] }.first
      shard[:files] << file
      shard[:seconds] += seconds
    end

    shards.each { |shard| shard[:files].sort! }
  end

  def default_seconds(files, timings)
    known = files.filter_map { |file| timings[file] }.sort
    return DEFAULT_SECONDS if known.empty?

    known[known.size / 2]
  end

  # 各シャードの記録（TestTimingsReporter の出力）を1つにまとめる。
  def merge(reports)
    tests = reports.flat_map { |report| report.fetch('tests').map { |test| test.merge('shard' => report['shard']) } }
    files = Hash.new(0.0)
    tests.each { |test| files[test.fetch('file')] += test.fetch('time') }

    { 'files' => files.sort.to_h.transform_values { |seconds| seconds.round(3) }, 'tests' => tests }
  end

  def load_file_timings(path)
    return {} unless path && File.exist?(path)

    JSON.parse(File.read(path)).fetch('files', {})
  end

  def summary(merged)
    tests = merged.fetch('tests')
    return "## テストの所要時間\n\n記録がありません。\n" if tests.empty?

    [
      '## テストの所要時間', '',
      '### シャードごとの合計', '', *shard_table(tests), '',
      "### 遅いファイル（上位#{SUMMARY_ROWS}件）", '', *file_table(merged.fetch('files')), '',
      "### 遅いテスト（上位#{SUMMARY_ROWS}件）", '', *test_table(tests), '',
      '### 再試行したテスト', '', *retry_table(tests), ''
    ].join("\n")
  end

  def shard_table(tests)
    rows = tests.group_by { |test| test['shard'] }.sort_by { |shard, _| shard.to_s }.map do |shard, shard_tests|
      retry_seconds = shard_tests.sum { |test| test.fetch('retry_time', 0) }
      "| #{shard} | #{shard_tests.size} | #{format_seconds(shard_tests.sum { |test| test.fetch('time') })} | #{format_seconds(retry_seconds)} |"
    end
    ['| シャード | テスト数 | 合計（秒） | 再試行に使った時間（秒） |', '| --- | ---: | ---: | ---: |', *rows]
  end

  def file_table(files)
    rows = files.sort_by { |file, seconds| [-seconds, file] }.first(SUMMARY_ROWS).map do |file, seconds|
      "| `#{file}` | #{format_seconds(seconds)} |"
    end
    ['| ファイル | 合計（秒） |', '| --- | ---: |', *rows]
  end

  def test_table(tests)
    rows = tests.sort_by { |test| [-test.fetch('time'), test_label(test)] }.first(SUMMARY_ROWS).map do |test|
      "| `#{test_label(test)}` | #{format_seconds(test.fetch('time'))} |"
    end
    ['| テスト | 時間（秒） |', '| --- | ---: |', *rows]
  end

  def retry_table(tests)
    retried = tests.select { |test| test.fetch('retries', 0).positive? }
    return ['再試行したテストはありません。'] if retried.empty?

    rows = retried.sort_by { |test| [-test.fetch('retry_time', 0), test_label(test)] }.map do |test|
      "| `#{test_label(test)}` | #{test.fetch('retries')} | #{format_seconds(test.fetch('retry_time', 0))} |"
    end
    ['| テスト | 再試行の回数 | 再試行に使った時間（秒） |', '| --- | ---: | ---: |', *rows]
  end

  def test_label(test)
    "#{test.fetch('class')}##{test.fetch('name')}"
  end

  def format_seconds(seconds)
    format('%.1f', seconds)
  end
end
