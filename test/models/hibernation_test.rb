# frozen_string_literal: true

require 'test_helper'

class HibernationTest < ActiveSupport::TestCase
  setup do
    @user = users(:kimura)
  end

  test 'cancel the pair works by the user' do
    hibernation = Hibernation.create!(
      user: @user,
      reason: '多忙のため',
      scheduled_return_on: Date.current + 3.months
    )
    pair_work = pair_works(:pair_work1)

    assert_difference 'PairWork.count', -2 do
      hibernation.send(:cancel_pair_works, @user)
    end

    assert_not PairWork.exists?(pair_work.id)
  end
end
