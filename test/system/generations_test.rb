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

  test 'kensyu user has all sns links' do
    visit_with_auth generation_path(5), 'kimura'

    user = users(:kensyu)
    within('.users-item', text: user.name) do
      assert_selector 'ul.sns-links__items'
      assert_selector 'li.sns-links__item', count: 5
      assert_selector "a.is-secondary[href='https://github.com/#{user.github_account}'] i.fa-github-alt", visible: :all
      assert_selector "a.is-secondary[href='https://twitter.com/#{user.twitter_account}'] i.fa-x-twitter", visible: :all
      assert_selector "a.is-secondary[href='#{user.facebook_url}'] i.fa-facebook-square", visible: :all
      assert_selector "a.is-secondary[href='#{user.blog_url}'] i.fa-blog", visible: :all
      assert_selector "a.is-secondary[href='#{user.discord_profile.times_url}'] i.fa-clock", visible: :all
    end
  end

  test 'kensyu user has company link' do
    visit_with_auth generation_path(5), 'kimura'

    user = users(:kensyu)
    within('.users-item', text: user.name) do
      find("a[href*='/companies/#{user.company.id}']").click
    end
    assert_selector 'h1', text: 'Fjord inc.'
  end

  test 'hajime user has no github, discord and company link' do
    visit_with_auth generation_path(5), 'kimura'

    user = users(:hajime)
    within('.users-item', text: user.name) do
      assert_selector 'ul.sns-links__items'
      assert_selector 'li.sns-links__item', count: 5
      assert_selector 'div.is-disabled  i.fa-github-alt', visible: :all
      assert_selector 'div.is-disabled  i.fa-clock', visible: :all
      assert_no_selector "a[href*='/companies/']"
    end
  end

  test 'show user tags in generation page' do
    user = users(:kimura)
    visit_with_auth generation_path(user.generation), 'kimura'

    within('.users-item', text: user.name) do
      user.tag_list.each do |tag|
        assert_text tag
      end
    end
  end

  test 'user tag links work in generation page' do
    user = users(:kimura)
    visit_with_auth generation_path(user.generation), 'kimura'

    tag_name = user.tag_list.first
    assert_text user.name
    within('.users-item', text: user.name) do
      click_link tag_name
    end
    assert_text "タグ「#{tag_name}」のユーザー"
  end

  test 'user tags display with correct CSS classes in generation page' do
    user = users(:kimura)
    visit_with_auth generation_path(user.generation), 'kimura'

    within('.users-item', text: user.name) do
      assert_selector '.tag-links'
      assert_selector '.tag-links__items'
      assert_selector '.tag-links__item'
      assert_selector '.tag-links__item-link'
    end
  end

  test 'user without tags does not show tag-links in generation page' do
    user = users(:otameshi)
    assert_empty user.tag_list

    visit_with_auth generation_path(user.generation), 'otameshi'

    within('.users-item', text: user.name) do
      assert_no_selector '.tag-links'
    end
  end

  test 'progress bar for graduated students should be 100%' do
    user = users(:sotugyou)

    visit_with_auth generation_path(user.generation), 'sotugyou'

    within('.users-item', text: user.name) do
      assert_text '100%'
    end
  end

  test 'progress bar for students who have not completed a single practice is 0%' do
    user = users(:hatsuno)

    visit_with_auth generation_path(user.generation), 'hatsuno'

    within('.users-item', text: user.name) do
      assert_text '0%'
    end
  end

  test 'no activity count is displayed except for students and trainees' do
    user = users(:komagata)

    visit_with_auth generation_path(user.generation), 'komagata'

    within('.users-item', text: user.name) do
      assert_no_selector '.card-counts'
    end
  end

  test 'a link will appear if there is activity' do
    user = users(:kimura)

    visit_with_auth generation_path(user.generation), 'kimura'

    within('.users-item', text: user.name) do
      assert_selector "a[href='/users/#{user.id}/reports']", text: '1'
      assert_selector "a[href='/users/#{user.id}/products']", text: '11'
      within('.card-counts__item-inner', text: 'コメント') do
        assert_selector '.is-empty'
      end
      assert_selector "a[href='/users/#{user.id}/questions']", text: '4'
      within('.card-counts__item-inner', text: '回答') do
        assert_selector '.is-empty'
      end
    end
  end
end
