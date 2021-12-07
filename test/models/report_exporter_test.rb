# frozen_string_literal: true

require 'test_helper'

class ReportExporterTest < ActiveSupport::TestCase
  test '#create' do
    reports = users(:kimura).reports
    filenames = Dir.mktmpdir('exports') do |folder_path|
      ReportExporter.new(reports, folder_path).create
    end

    assert_equal reports.map { |report| "#{report.reported_on}.md" }.sort, filenames
  end
end
