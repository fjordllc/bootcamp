# frozen_string_literal: true

require 'test_helper'

class UnfinishedDataDestroyerTest < ActiveSupport::TestCase
  setup do
    @user = users(:kimura)
    3.times do |i|
      Report.create!(
        user: @user,
        title: "wipの日報#{i}",
        description: 'テスト日報',
        wip: true,
        reported_on: Date.current - i
      )
    end
    @payload = { user: @user }
  end

  test '#call deletes user wip reports and unchecked products and resets career_path' do
    @user.update!(career_path: 1)

    UnfinishedDataDestroyer.new.call(nil, nil, nil, nil, @payload)

    assert_equal 0, Product.unchecked.where(user: @user).count
    assert_equal 0, Report.wip.where(user: @user).count
    assert_equal 'unset', @user.reload.career_path
  end

  test 'does not delete other users wip report and unchecked product' do
    other_user_unchecked_product = products(:product1)
    other_user_wip_report = reports(:report9)

    UnfinishedDataDestroyer.new.call(nil, nil, nil, nil, @payload)

    assert Product.exists?(other_user_unchecked_product.id)
    assert Report.exists?(other_user_wip_report.id)
  end

  test 'does not delete checked product or non-wip report' do
    checked_product = products(:product2)
    non_wip_report = reports(:report24)

    UnfinishedDataDestroyer.new.call(nil, nil, nil, nil, @payload)

    assert Product.exists?(checked_product.id)
    assert Report.exists?(non_wip_report.id)
  end
end
