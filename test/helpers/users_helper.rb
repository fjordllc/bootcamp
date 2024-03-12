# frozen_string_literal: true

require 'test_helper'

class UsersHelperTest < ActionView::TestCase
  test 'all_countries_with_subdivisions' do
    countries = JSON.parse(all_countries_with_subdivisions)
    assert_includes countries['JP'], %w[北海道 01]
    assert_includes countries['US'], %w[アラスカ州 AK]
  end

  test 'link_or_text_for_count' do
    assert_equal '0', link_or_text_for_count(0, user_path(users(:kimura)))
    assert_dom_equal %{<a href="/users/#{users(:kimura).id}">1</a>}, link_or_text_for_count(1, user_path(users(:kimura)))
  end
end
