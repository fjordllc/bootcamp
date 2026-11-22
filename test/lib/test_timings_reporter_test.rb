# frozen_string_literal: true

require 'test_helper'

class TestTimingsReporterTest < ActiveSupport::TestCase
  Result = Struct.new(:klass, :name, :time, :source_location)

  test 'writes the time and retries of each test with a path relative to the root' do
    Dir.mktmpdir do |dir|
      path = "#{dir}/nested/shard-3.json"
      reporter = TestTimingsReporter.new(path, root: Rails.root.to_s, shard: '3')

      reporter.record_retry(self.class.name, 'test_flaky', Result.new(self.class.name, 'test_flaky', 4.0, [__FILE__, 1]))
      reporter.record_retry(self.class.name, 'test_flaky', Result.new(self.class.name, 'test_flaky', 5.0, [__FILE__, 1]))
      reporter.record(Result.new(self.class.name, 'test_flaky', 1.23456, [__FILE__, 1]))
      reporter.record(Result.new(self.class.name, 'test_stable', 0.5, [__FILE__, 1]))
      reporter.report

      report = JSON.parse(File.read(path))
      assert_equal '3', report['shard']
      common = { 'file' => 'test/lib/test_timings_reporter_test.rb', 'class' => self.class.name }
      assert_equal [
        common.merge('name' => 'test_flaky', 'time' => 1.235, 'retries' => 2, 'retry_time' => 9.0),
        common.merge('name' => 'test_stable', 'time' => 0.5, 'retries' => 0, 'retry_time' => 0.0)
      ], report['tests']
    end
  end

  test 'report can be merged by CiTestTimings' do
    Dir.mktmpdir do |dir|
      reporter = TestTimingsReporter.new("#{dir}/shard-0.json", root: Rails.root.to_s, shard: '0')
      reporter.record(Result.new(self.class.name, 'test_one', 2.0, [__FILE__, 1]))
      reporter.report

      merged = CiTestTimings.merge([JSON.parse(File.read("#{dir}/shard-0.json"))])

      assert_equal({ 'test/lib/test_timings_reporter_test.rb' => 2.0 }, merged['files'])
    end
  end
end
