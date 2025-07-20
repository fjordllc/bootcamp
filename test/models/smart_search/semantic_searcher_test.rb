# frozen_string_literal: true

require 'test_helper'

module SmartSearch
  class SemanticSearcherTest < ActiveSupport::TestCase
    test 'searchable_models includes Report and Product' do
      searcher = SmartSearch::SemanticSearcher.new
      models = searcher.send(:searchable_models)

      assert_includes models, Report
      assert_includes models, Product
    end

    test 'type_to_model returns correct models for reports and products' do
      searcher = SmartSearch::SemanticSearcher.new

      assert_equal Report, searcher.send(:type_to_model, :reports)
      assert_equal Product, searcher.send(:type_to_model, :products)
    end
  end
end
