# frozen_string_literal: true

require 'test_helper'

class UnfinishedDataDestroyerTest < ActiveSupport::TestCase
  setup do
    @user = users(:kimura)
    @reports = 3.times.map do |i|
      Report.create!(
        user: @user,
        title: "wipの日報#{i}",
        description: 'テスト日報',
        wip: true, reported_on: Date.current - i
      )
    end
    @payload = { user: @user }
  end
  test '#call' do
    @user.update(career_path: 1)
    product = products(:product5)
    report = @reports.first

    UnfinishedDataDestroyer.new.call(nil, nil, nil, nil, @payload)
    assert_not Report.exists?(report.id)
    assert_not Product.exists?(product.id)
    assert_equal 'unset', @user.reload.career_path
  end

  test 'deletes all wip reports and unchecked products for user but other users remain unaffected' do
    user_unchecked_products = [products(:product5), products(:product8), products(:product10)]
    user_wip_reports = @reports

    other_unchecked_product = products(:product1)
    other_wip_report = reports(:report9)

    UnfinishedDataDestroyer.new.call(nil, nil, nil, nil, @payload)

    assert_not Product.where(id: user_unchecked_products).exists?
    assert_not Report.where(id: user_wip_reports).exists?

    assert Product.exists?(other_unchecked_product.id)
    assert Report.exists?(other_wip_report.id)
  end

  test 'does not delete checked product or unwip report' do
    product = products(:product2)
    report = reports(:report24)

    UnfinishedDataDestroyer.new.call(nil, nil, nil, nil, @payload)

    assert Product.exists?(product.id)
    assert Report.exists?(report.id)
  end
end
