# frozen_string_literal: true

require 'application_system_test_case'

# 対象ごとの絞り込みは test/integration/generations_filter_test.rb と test/models/generation_test.rb で確かめる。
module Generations
  class FilterTest < ApplicationSystemTestCase
    test 'all users filter for generation' do
      travel_to Time.zone.local(2021, 4, 1, 0, 0, 0) do
        visit_with_auth '/generations', 'komagata'

        assert_selector('a.tab-nav__item-link.is-active', text: '全員')
        assert_text '期生別（全員）'
        assert_link '33期生'
        assert_text '2021年01月01日 ~ 2021年03月31日'
        assert_text '現役生'
        assert_selector '.card-counts__item-value', text: '2'
        assert_text '研修生'
        assert_selector '.card-counts__item-value', text: '0'
        assert_text '休会'
        assert_selector '.card-counts__item-value', text: '0'
        assert_text '卒業生'
        assert_selector '.card-counts__item-value', text: '0'
        assert_text 'アドバイザー'
        assert_selector '.card-counts__item-value', text: '0'
        assert_text '退会者'
        assert_selector '.card-counts__item-value', text: '0'
        within all('.a-user-icons__items').first do
          within first('.a-user-role.is-admin') do
            assert_equal first('.a-user-icons__item-icon.a-user-icon')['title'], 'adminonly (アドミン 能美代): 管理者'
          end
        end
        assert_link '5期生'
        assert_text '2014年01月01日 ~ 2014年03月31日'
        assert_text '現役生'
        assert_selector '.card-counts__item-value', text: '18'
        assert_text '研修生'
        assert_selector '.card-counts__item-value', text: '3'
        assert_text '休会'
        assert_selector '.card-counts__item-value', text: '1'
        assert_text '卒業生'
        assert_selector '.card-counts__item-value', text: '2'
        assert_text '退会者'
        assert_selector '.card-counts__item-value', text: '2'
        assert_text 'アドバイザー'
        assert_selector '.card-counts__item-value', text: '2'
        within all('.a-user-icons__items').last do
          within first('.a-user-role.is-student') do
            assert_equal first('.a-user-icons__item-icon.a-user-icon')['title'], 'marumarushain1 (marumarushain1)'
          end
          within first('.a-user-role.is-trainee') do
            assert_equal first('.a-user-icons__item-icon.a-user-icon')['title'], 'kensyu (Kensyu Seiko)'
          end
          within first('.a-user-role.is-adviser') do
            assert_equal first('.a-user-icons__item-icon.a-user-icon')['title'], 'advijirou (アドバイ 次郎): アドバイザー'
          end
          within first('.a-user-role.is-graduate') do
            assert_equal first('.a-user-icons__item-icon.a-user-icon')['title'], 'sotugyou (卒業 太郎)'
          end
          within all('.a-user-role.is-mentor').last do
            assert_equal first('.a-user-icons__item-icon.a-user-icon')['title'], 'mentormentaro (メンタ 麺太郎): メンター'
          end
          assert_no_selector '.a-user-role.is-retired'
        end
      end
    end
  end
end
