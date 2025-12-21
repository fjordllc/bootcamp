# frozen_string_literal: true

require 'test_helper'

class UnfinishedDataDestroyerTest < ActiveSupport::TestCase
  setup do
    @payload = { user: users(:kimura) }
  end

  test '#call deletes user wip reports and unchecked products and resets career_path' do
    user = @payload[:user]
    user.update!(career_path: 1)

    3.times do |i|
      Report.create!(
        user:,
        title: "wipの日報#{i}",
        description: 'テスト日報',
        wip: true,
        reported_on: Date.current - i
      )
    end

    practices = Practice.where.not(id: user.products.pluck(:practice_id)).take(3)
    practices.each do |practice|
      Product.create!(
        user:,
        practice:,
        body: '提出物',
        wip: false
      )
    end

    UnfinishedDataDestroyer.new.call(nil, nil, nil, nil, @payload)

    assert_equal 0, Product.unchecked.where(user:).count
    assert_equal 0, Report.wip.where(user:).count
    assert_equal 'unset', user.reload.career_path
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
