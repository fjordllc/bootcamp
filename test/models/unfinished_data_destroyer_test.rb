# frozen_string_literal: true

require 'test_helper'

class UnfinishedDataDestroyerTest < ActiveSupport::TestCase
  test '#call' do
    user = users(:sotugyou)
    user.update(job: 'office_worker', career_path: 1)

    wip_report = reports(:report9)
    unchecked_product = products(:product6)
    payload = { user: }

    UnfinishedDataDestroyer.new.call(nil, nil, nil, nil, payload)
    assert_not Report.exists?(wip_report.id)
    assert_not Product.exists?(unchecked_product.id)
    assert_equal 'unset', user.reload.career_path
  end
end
