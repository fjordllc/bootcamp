# frozen_string_literal: true

require 'test_helper'

class GithubContributionTest < ActiveSupport::TestCase
  test '#generate_table' do
    VCR.use_cassette 'github_contribution/fetch' do
      assert_equal GithubContribution.new('komagata').generate_table.size, 7
      assert_equal GithubContribution.new('komagata1234').generate_table.size, 0
    end
  end
end
