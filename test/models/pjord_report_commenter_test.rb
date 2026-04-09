# frozen_string_literal: true

require 'test_helper'

class PjordReportCommenterTest < ActiveJob::TestCase
  test 'enqueues PjordReportCommentJob when report is first published' do
    report = reports(:report1)
    report.update_column(:wip, false) # rubocop:disable Rails/SkipsModelValidations
    report.update_column(:published_at, nil) # rubocop:disable Rails/SkipsModelValidations
    commenter = PjordReportCommenter.new

    assert_enqueued_with(job: PjordReportCommentJob, args: [{ report_id: report.id }]) do
      commenter.call('report.create', Time.current, Time.current, 'unique_id', report: report)
    end
  end

  test 'does not enqueue when report is WIP' do
    report = reports(:report1)
    report.update_column(:wip, true) # rubocop:disable Rails/SkipsModelValidations
    commenter = PjordReportCommenter.new

    assert_no_enqueued_jobs(only: PjordReportCommentJob) do
      commenter.call('report.create', Time.current, Time.current, 'unique_id', report: report)
    end
  end

  test 'does not enqueue when report is already published' do
    report = reports(:report1)
    report.update_column(:wip, false) # rubocop:disable Rails/SkipsModelValidations
    report.update_column(:published_at, Time.current) # rubocop:disable Rails/SkipsModelValidations
    commenter = PjordReportCommenter.new

    assert_no_enqueued_jobs(only: PjordReportCommentJob) do
      commenter.call('report.update', Time.current, Time.current, 'unique_id', report: report)
    end
  end
end
