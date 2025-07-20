# frozen_string_literal: true

require 'test_helper'

class BulkEmbeddingJobTest < ActiveJob::TestCase
  test 'SEARCHABLE_MODELS includes Report and Product' do
    assert_includes BulkEmbeddingJob::SEARCHABLE_MODELS, 'Report'
    assert_includes BulkEmbeddingJob::SEARCHABLE_MODELS, 'Product'
  end

  test 'extract_text_content for Report' do
    report = reports(:report1)
    job = BulkEmbeddingJob.new
    text = job.send(:extract_text_content, report)

    assert_includes text, report.title
    assert_includes text, report.description if report.description.present?
  end

  test 'extract_text_content for Product' do
    product = products(:product1)
    job = BulkEmbeddingJob.new
    text = job.send(:extract_text_content, product)

    assert_equal product.body, text
  end
end
