# frozen_string_literal: true

require 'test_helper'

class  SearchHelperTest < ActionView::TestCase
  test 'does it return correct boolean value in talk' do
    user = users(:kimura)
    assert_equal true, talk?(user)
  end

  test 'can get correct user id' do
    user = users(:kimura)
    assert_equal 915604563, find_talk_id_from_user_id(user)
  end
end
