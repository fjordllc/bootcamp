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

    latest_generation = Generation.latest_generation_number
    assert_link "#{latest_generation}期生"
    assert_equal '期生別ユーザー一覧 | FBC', title
  end

  test 'no retired fileter when login without admin' do
    visit_with_auth '/generations', 'kimura'
    assert_no_text '退会'
  end

  test 'all users filter for generation' do
    visit_with_auth '/generations', 'komagata'

    assert_selector('a.tab-nav__item-link.is-active', text: '全員')
    assert_text '期生別（全員）'
    within all('.a-user-icons__items')[-3] do
      assert_equal first('.a-user-icons__item-icon.a-user-icon.is-admin')['title'], 'adminonly (アドミン 能美代): 管理者'
    end
    within all('.a-user-icons__items').last do
      assert_equal first('.a-user-icons__item-icon.a-user-icon.is-student')['title'], 'marumarushain1 (marumarushain1)'
      assert_equal first('.a-user-icons__item-icon.a-user-icon.is-trainee')['title'], 'kensyu (Kensyu Seiko)'
      assert_equal first('.a-user-icons__item-icon.a-user-icon.is-adviser')['title'], 'advijirou (アドバイ 次郎): アドバイザー'
      assert_equal first('.a-user-icons__item-icon.a-user-icon.is-graduate')['title'], 'sotugyou-with-job (卒業 就職済美)'
      assert_equal all('.a-user-icons__item-icon.a-user-icon.is-mentor').last['title'], 'mentormentaro (メンタ 麺太郎): メンター'
      all('.a-user-icons__item-icon.a-user-icon.is-student').each do |selector|
        assert_not_equal selector['title'], 'yameo (辞目 辞目夫)'
      end
    end
  end

  test 'trainee users filter for generation' do
    visit_with_auth '/generations?target=trainee', 'komagata'

    assert_selector('a.tab-nav__item-link.is-active', text: '研修生')
    assert_text '期生別（研修生）'
    within all('.a-user-icons__items').last do
      assert_equal first('.a-user-icons__item-icon.a-user-icon.is-trainee')['title'], 'kensyu (Kensyu Seiko)'
      all('.a-user-icons__item-icon.a-user-icon.is-student').each do |selector|
        assert_not_equal selector['title'], 'yameo (辞目 辞目夫)'
      end
    end
  end

  test 'adviser users filter for generation' do
    visit_with_auth '/generations?target=adviser', 'komagata'

    assert_selector('a.tab-nav__item-link.is-active', text: 'アドバイザー')
    assert_text '期生別（アドバイザー）'
    within all('.a-user-icons__items').last do
      assert_equal first('.a-user-icons__item-icon.a-user-icon.is-adviser')['title'], 'advijirou (アドバイ 次郎): アドバイザー'
      all('.a-user-icons__item-icon.a-user-icon.is-student').each do |selector|
        assert_not_equal selector['title'], 'yameo (辞目 辞目夫)'
      end
    end
  end

  test 'graduate users filter for generation' do
    visit_with_auth '/generations?target=graduate', 'komagata'

    assert_selector('a.tab-nav__item-link.is-active', text: '卒業生')
    assert_text '期生別（卒業生）'
    within all('.a-user-icons__items').last do
      assert_equal first('.a-user-icons__item-icon.a-user-icon.is-graduate')['title'], 'sotugyou-with-job (卒業 就職済美)'
      all('.a-user-icons__item-icon.a-user-icon.is-student').each do |selector|
        assert_not_equal selector['title'], 'yameo (辞目 辞目夫)'
      end
    end
  end

  test 'mentor users filter for generation' do
    visit_with_auth '/generations?target=mentor', 'komagata'

    assert_selector('a.tab-nav__item-link.is-active', text: 'メンター')
    assert_text '期生別（メンター）'
    within all('.a-user-icons__items').last do
      assert_equal all('.a-user-icons__item-icon.a-user-icon.is-mentor').last['title'], 'mentormentaro (メンタ 麺太郎): メンター'
      all('.a-user-icons__item-icon.a-user-icon.is-student').each do |selector|
        assert_not_equal selector['title'], 'yameo (辞目 辞目夫)'
      end
    end
  end

  test 'retired users filter for generation' do
    visit_with_auth '/generations?target=retired', 'adminonly'

    assert_selector('a.tab-nav__item-link.is-active', text: '退会')
    assert_text '期生別（退会）'
    within all('.a-user-icons__items').last do
      assert_equal first('.a-user-icons__item-icon.a-user-icon.is-student')['title'], 'yameo (辞目 辞目夫)'
    end
  end
end
