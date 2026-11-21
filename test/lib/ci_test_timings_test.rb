# frozen_string_literal: true

require 'test_helper'
require 'open3'

class CiTestTimingsTest < ActiveSupport::TestCase
  test 'split balances shards by recorded seconds' do
    timings = { 'a_test.rb' => 100.0, 'b_test.rb' => 50.0, 'c_test.rb' => 30.0, 'd_test.rb' => 20.0 }

    shards = CiTestTimings.split(timings.keys, timings, 2)

    assert_equal [%w[a_test.rb], %w[b_test.rb c_test.rb d_test.rb]], shards.pluck(:files)
    assert_equal [100.0, 100.0], shards.pluck(:seconds)
  end

  test 'split assigns every file exactly once' do
    files = Array.new(50) { |index| "test/models/file#{index}_test.rb" }
    timings = files.first(30).each_with_index.to_h { |file, index| [file, index * 1.5] }

    shards = CiTestTimings.split(files, timings, 8)

    assert_equal files.sort, shards.flat_map { |shard| shard[:files] }.sort
    assert(shards.none? { |shard| shard[:files].empty? })
  end

  test 'split spreads files evenly when no timings are recorded' do
    files = Array.new(10) { |index| "file#{index}_test.rb" }

    shards = CiTestTimings.split(files, {}, 3)

    assert_equal([4, 3, 3], shards.map { |shard| shard[:files].size })
  end

  test 'split treats files without timings as the median of recorded files' do
    timings = { 'a_test.rb' => 10.0, 'b_test.rb' => 20.0, 'c_test.rb' => 30.0, 'removed_test.rb' => 999.0 }

    shards = CiTestTimings.split(%w[a_test.rb b_test.rb c_test.rb new_test.rb], timings, 2)

    assert_equal [%w[a_test.rb c_test.rb], %w[b_test.rb new_test.rb]], shards.pluck(:files)
    assert_equal [40.0, 40.0], shards.pluck(:seconds)
  end

  test 'split gives the same result regardless of input order' do
    timings = { 'a_test.rb' => 3.0, 'b_test.rb' => 3.0, 'c_test.rb' => 1.0 }
    files = %w[a_test.rb b_test.rb c_test.rb d_test.rb]

    assert_equal CiTestTimings.split(files, timings, 2), CiTestTimings.split(files.reverse, timings, 2)
  end

  test 'merge sums final run seconds per file and keeps the shard of each test' do
    reports = [
      { 'shard' => '0', 'tests' => [test_entry('a_test.rb', 'test_one', 1.5), test_entry('a_test.rb', 'test_two', 2.0, retries: 1, retry_time: 9.0)] },
      { 'shard' => '1', 'tests' => [test_entry('b_test.rb', 'test_three', 0.25)] }
    ]

    merged = CiTestTimings.merge(reports)

    assert_equal({ 'a_test.rb' => 3.5, 'b_test.rb' => 0.25 }, merged['files'])
    assert_equal %w[0 0 1], merged['tests'].pluck('shard')
  end

  test 'summary lists shard totals, slow files, slow tests and retried tests' do
    reports = [{ 'shard' => '0', 'tests' => [test_entry('a_test.rb', 'test_one', 1.5), test_entry('a_test.rb', 'test_two', 2.0, retries: 1, retry_time: 9.0)] }]

    summary = CiTestTimings.summary(CiTestTimings.merge(reports))

    assert_includes summary, '| 0 | 2 | 3.5 | 9.0 |'
    assert_includes summary, '| `a_test.rb` | 3.5 |'
    assert_includes summary, '| `SampleTest#test_two` | 2.0 |'
    assert_includes summary, '| `SampleTest#test_two` | 1 | 9.0 |'
  end

  test 'summary says so when nothing was recorded' do
    assert_includes CiTestTimings.summary(CiTestTimings.merge([])), '記録がありません。'
  end

  test 'command splits the repository test files and merges shard reports' do
    Dir.mktmpdir do |dir|
      File.write("#{dir}/timings.json", JSON.generate(files: { 'test/lib/ci_test_timings_test.rb' => 5.0 }))
      output, status = run_command('split', '--shards', '4', '--timings', "#{dir}/timings.json", '--output', "#{dir}/shards")
      assert status.success?, output
      selected = Array.new(4) { |index| File.readlines("#{dir}/shards/shard-#{index}.txt", chomp: true) }
      assert_equal Rails.root.glob('test/**/*_test.rb').map { |path| path.relative_path_from(Rails.root).to_s }.sort, selected.flatten.sort

      FileUtils.mkdir_p("#{dir}/reports/nested")
      File.write("#{dir}/reports/nested/shard-0.json", JSON.generate(shard: '0', tests: [test_entry('a_test.rb', 'test_one', 1.5)]))
      output, status = run_command('merge', '--input', "#{dir}/reports", '--output', "#{dir}/out/merged.json", '--summary', "#{dir}/summary.md")
      assert status.success?, output
      assert_equal({ 'a_test.rb' => 1.5 }, CiTestTimings.load_file_timings("#{dir}/out/merged.json"))
      assert_includes File.read("#{dir}/summary.md"), '| `a_test.rb` | 1.5 |'
    end
  end

  test 'load_file_timings returns nothing when the file is missing' do
    assert_empty CiTestTimings.load_file_timings('tmp/no_such_test_timings.json')
  end

  private

  def test_entry(file, name, time, retries: 0, retry_time: 0.0)
    { 'file' => file, 'class' => 'SampleTest', 'name' => name, 'time' => time, 'retries' => retries, 'retry_time' => retry_time }
  end

  def run_command(*)
    Open3.capture2e(RbConfig.ruby, Rails.root.join('bin/ci-test-timings').to_s, *, chdir: Rails.root.to_s)
  end
end
