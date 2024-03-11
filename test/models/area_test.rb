# frozen_string_literal: true

require 'test_helper'

class AreaTest < ActiveSupport::TestCase
  test '#users' do
    assert_includes Area.users('海外', '米国'), users(:tom)
    assert_includes Area.users('関東地方', '東京都'), users(:kimura)
  end

  test '#number_of_users_by_region' do
    assert_equal Area.number_of_users_by_region, {
      '関東地方' => { '東京都' => 1, '栃木県' => 1 },
      '九州・沖縄地方' => { '長崎県' => 1 },
      '海外' => { '米国' => 2, 'カナダ' => 1 }
    }
  end
end
