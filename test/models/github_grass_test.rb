# frozen_string_literal: true

require 'test_helper'

class GithubGrassTest < ActiveSupport::TestCase
  test '#fetch' do
    VCR.use_cassette 'github_grass/fetch' do
      assert_match(/table/, GithubGrass.new('komagata').fetch)
      assert_no_match(/table/, GithubGrass.new('komagata1234').fetch)
    end
  end
end
