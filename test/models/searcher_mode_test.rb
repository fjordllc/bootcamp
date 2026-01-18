# frozen_string_literal: true

require 'test_helper'

class SearcherModeTest < ActiveSupport::TestCase
  def current_user
    users(:kimura)
  end

  test 'default mode is keyword' do
    searcher = Searcher.new(keyword: 'test', current_user:)
    assert_equal :keyword, searcher.mode
  end

  test 'MODES constant contains all valid modes' do
    assert_equal %i[keyword semantic hybrid], Searcher::MODES
  end
end
