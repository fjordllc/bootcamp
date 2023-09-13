# frozen_string_literal: true

require 'application_system_test_case'

class BuzzTest < ApplicationSystemTestCase
  test 'non-logged-in user can access /buzz' do
    visit buzz_url
    assert_text '紹介・言及記事'
    assert_text '本文1'
  end

  test 'admin can update buzz' do
    visit_with_auth edit_buzz_url, 'komagata'

    fill_in 'buzz[body]', with: 'adminが書き換えました'
    click_on '更新する'

    assert_text 'adminが書き換えました'
    assert_text '紹介・言及記事を更新しました'
  end

  test 'mentor can update buzz' do
    visit_with_auth edit_buzz_url, 'mentormentaro'

    fill_in 'buzz[body]', with: 'mentorが書き換えました'
    click_on '更新する'

    assert_text 'mentorが書き換えました'
    assert_text '紹介・言及記事を更新しました'
  end

  test 'regular user cannot update buzz' do
    visit_with_auth buzz_url, 'kimura'

    assert_no_text '内容修正'

    visit edit_buzz_path
    assert_text '管理者・メンターとしてログインしてください'
  end

  test 'body should not be blank' do
    visit_with_auth edit_buzz_url, 'komagata'

    fill_in 'buzz[body]', with: ''
    click_on '更新する'

    assert_text '本文を入力してください'
  end
end
