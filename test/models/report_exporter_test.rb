# frozen_string_literal: true

require 'test_helper'

class ReportExporterTest < ActiveSupport::TestCase
  test '#export' do
    reports = users(:hajime).reports
    filenames = Dir.mktmpdir do |folder_path|
      ReportExporter.export(reports, folder_path)
    end

    assert_equal reports.map { |report| "#{report.reported_on}.md" }.sort, filenames
  end
end
