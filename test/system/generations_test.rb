# frozen_string_literal: true

require 'application_system_test_case'

class GenerationsTest < ApplicationSystemTestCase
  test 'show same generation users' do
    visit_with_auth generation_path(users(:kimura).generation), 'kimura'
    assert_equal "#{users(:kimura).generation}期のユーザー一覧 | FBC", title
    assert_text users(:kimura).name
    assert_text users(:komagata).name
  end

  test 'show no same generation users' do
    visit_with_auth generation_path(0), 'kimura'
    assert_text '0期のユーザー一覧はありません'
  end

  test 'show generations' do
    visit_with_auth generations_path, 'kimura'
    assert_text 'ユーザー一覧'
    assert_link "#{users(:otameshi).generation}期生"
    within all('.a-user-icons__items').first do
      within first('.a-user-role.is-student') do
        assert_equal first('img')['class'], 'a-user-icons__item-icon a-user-icon'
      end
    end
    assert_equal '期生別ユーザー一覧 | FBC', title
  end

  test 'no retired fileter when login without admin' do
    travel_to Time.zone.local(2022, 1, 1, 0, 0, 0) do
      visit_with_auth '/generations', 'kimura'
      assert_no_text '退会'
    end
  end

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
        assert_empty all('.a-user-role.is-retired')
      end
    end
  end

  test 'trainee users filter for generation' do
    travel_to Time.zone.local(2014, 4, 1, 0, 0, 0) do
      visit_with_auth '/generations?target=trainee', 'komagata'

      assert_selector('a.tab-nav__item-link.is-active', text: '研修生')
      assert_text '期生別（研修生）'
      assert_link '5期生'
      assert_text '2014年01月01日 ~ 2014年03月31日'
      within all('.a-user-icons__items').last do
        within first('.a-user-role.is-trainee') do
          assert_equal first('.a-user-icons__item-icon.a-user-icon')['title'], 'kensyu (Kensyu Seiko)'
        end
        assert_empty all('.a-user-role.is-retired')
      end
    end
  end

  test 'adviser users filter for generation' do
    travel_to Time.zone.local(2014, 4, 1, 0, 0, 0) do
      visit_with_auth '/generations?target=adviser', 'komagata'

      assert_selector('a.tab-nav__item-link.is-active', text: 'アドバイザー')
      assert_text '期生別（アドバイザー）'
      assert_link '5期生'
      assert_text '2014年01月01日 ~ 2014年03月31日'
      within all('.a-user-icons__items').last do
        within first('.a-user-role.is-adviser') do
          assert_equal first('.a-user-icons__item-icon.a-user-icon')['title'], 'advijirou (アドバイ 次郎): アドバイザー'
        end
        assert_empty all('.a-user-role.is-retired')
      end
    end
  end

  test 'graduate users filter for generation' do
    travel_to Time.zone.local(2014, 4, 1, 0, 0, 0) do
      visit_with_auth '/generations?target=graduate', 'komagata'

      assert_selector('a.tab-nav__item-link.is-active', text: '卒業生')
      assert_text '期生別（卒業生）'
      assert_link '5期生'
      assert_text '2014年01月01日 ~ 2014年03月31日'
      within all('.a-user-icons__items').last do
        within first('.a-user-role.is-graduate') do
          assert_equal first('.a-user-icons__item-icon.a-user-icon')['title'], 'sotugyou (卒業 太郎)'
        end
        assert_empty all('.a-user-role.is-retired')
      end
    end
  end

  test 'mentor users filter for generation' do
    travel_to Time.zone.local(2014, 4, 1, 0, 0, 0) do
      visit_with_auth '/generations?target=mentor', 'komagata'

      assert_selector('a.tab-nav__item-link.is-active', text: 'メンター')
      assert_text '期生別（メンター）'
      assert_link '5期生'
      assert_text '2014年01月01日 ~ 2014年03月31日'
      within all('.a-user-icons__items').last do
        within all('.a-user-role.is-mentor').last do
          assert_equal first('.a-user-icons__item-icon.a-user-icon')['title'], 'mentormentaro (メンタ 麺太郎): メンター'
        end
        assert_empty all('.a-user-role.is-retired')
      end
    end
  end

  test 'retired users filter for generation' do
    travel_to Time.zone.local(2014, 4, 1, 0, 0, 0) do
      visit_with_auth '/generations?target=retired', 'adminonly'

      assert_selector('a.tab-nav__item-link.is-active', text: '退会')
      assert_text '期生別（退会）'
      assert_link '5期生'
      assert_text '2014年01月01日 ~ 2014年03月31日'
      within all('.a-user-icons__items').last do
        within first('.a-user-role.is-retired') do
          assert_equal first('.a-user-icons__item-icon.a-user-icon')['title'], 'yameo (辞目 辞目夫)'
        end
      end
    end
  end
end
