# frozen_string_literal: true

require 'test_helper'

class RegionTest < ActiveSupport::TestCase
  test '#users' do
    assert_includes Region.users('米国', '海外'), users(:tom)
    assert_includes Region.users('東京都', '関東地方'), users(:kimura)
  end

  test '#number_of_users_by_region' do
    assert_equal Region.number_of_users_by_region, {
      '関東地方' => { '東京都' => 1, '栃木県' => 1 },
      '九州・沖縄地方' => { '長崎県' => 1 },
      '海外' => { '米国' => 2, 'カナダ' => 1 }
    }
  end
end
