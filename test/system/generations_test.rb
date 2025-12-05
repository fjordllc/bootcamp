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

  test 'navigates to user activity when clicking count link' do
    user = users(:kimura)

    visit_with_auth generation_path(user.generation), 'kimura'

    within('.users-item', text: user.name) do
      assert_selector "a[href='/users/#{user.id}/reports']", text: '1'
      within('.card-counts__item-inner', text: '日報') do
        click_link user.reports.count.to_s
      end
      assert_current_path("/users/#{user.id}/reports")
    end

    visit generation_path(user.generation)

    within('.users-item', text: user.name) do
      assert_selector "a[href='/users/#{user.id}/products']", text: '11'
      within('.card-counts__item-inner', text: '提出物') do
        click_link user.products.count.to_s
      end
      assert_current_path("/users/#{user.id}/products")
    end

    visit generation_path(user.generation)

    within('.users-item', text: user.name) do
      assert_selector "a[href='/users/#{user.id}/questions']", text: '4'
      within('.card-counts__item-inner', text: '質問') do
        click_link user.questions.count.to_s
      end
      assert_current_path("/users/#{user.id}/questions")
    end
  end

  test 'shows 0 without link when user has no activity' do
    user = users(:kimura)
    visit_with_auth generation_path(user.generation), 'kimura'

    within('.users-item', text: user.name) do
      within('.card-counts__item-inner', text: 'コメント') do
        assert_selector '.is-empty'
        assert_text '0'
      end

      within('.card-counts__item-inner', text: '回答') do
        assert_selector '.is-empty'
        assert_text '0'
      end
    end
  end
end
