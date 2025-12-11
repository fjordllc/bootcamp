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
end
