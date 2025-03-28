# frozen_string_literal: true

require 'test_helper'

class AreaTest < ActiveSupport::TestCase
  test '#number_of_users_by_region' do
    assert_equal Area.number_of_users_by_region, {
      '関東地方' => { '東京都' => 3, '栃木県' => 1 },
      '九州・沖縄地方' => { '長崎県' => 1 },
      '海外' => { '米国' => 2, 'カナダ' => 1 }
    }
  end

  test '#sorted_user_groups_by_area_user_num' do
    sorted_users_group_by_areas = Area.sorted_user_groups_by_area_user_num
    tokyo_users = [users(:adminonly), users(:machida), users(:kimura)].sort_by(&:created_at).reverse
    tochigi_users = [users(:kyuukai)]
    nagasaki_users = [users(:advisernocolleaguetrainee)]
    america_users = [users(:neverlogin), users(:tom)].sort_by(&:created_at).reverse
    canada_users = [users(:sotsugyoukigyoshozoku)]

    assert_equal sorted_users_group_by_areas[0][:area], '東京都'
    assert_equal sorted_users_group_by_areas[1][:area], '米国'
    assert_equal sorted_users_group_by_areas.detect { _1[:area] == '東京都' }[:users], tokyo_users
    assert_equal sorted_users_group_by_areas.detect { _1[:area] == '米国' }[:users], america_users
    assert_equal sorted_users_group_by_areas.detect { _1[:area] == '栃木県' }[:users], tochigi_users
    assert_equal sorted_users_group_by_areas.detect { _1[:area] == '長崎県' }[:users], nagasaki_users
    assert_equal sorted_users_group_by_areas.detect { _1[:area] == 'カナダ' }[:users], canada_users
  end
end
