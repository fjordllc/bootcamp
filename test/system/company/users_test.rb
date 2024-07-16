# frozen_string_literal: true

require 'application_system_test_case'

class Company::UsersTest < ApplicationSystemTestCase
  test 'show users' do
    visit_with_auth "/companies/#{companies(:company1).id}/users", 'kimura'
    assert_equal 'Lokka Inc.所属ユーザー | FBC', title
  end

  test 'show users by user category' do
    visit_with_auth "/companies/#{companies(:company2).id}/users", 'kimura'
    # デフォルトは現役 + 研修生のユーザーを表示
    # Kensyu Owata は研修を終えている研修生
    assert_no_text 'Kensyu Owata'

    click_link '全員'
    assert_text 'Kensyu Owata'

    click_link '現役 + 研修生'
    assert_no_text 'Kensyu Owata'
  end

  test 'show pagination when over 25 users' do
    25.times do |i|
      user = User.create!(
        login_name: "paginationtest#{i}",
        email: "paginationtest#{i}@fjord.jp",
        password: 'testtest',
        name: "pagination#{i}",
        name_kana: 'ページネーション テスト',
        description: 'ページネーションテスト用に一時的なユーザーを作成しました',
        course: courses(:course1),
        job: 'student',
        os: 'mac',
        company: companies(:company1),
        experience: 'ruby'
      )

      DiscordProfile.create!(
        user_id: user.id,
        times_url: 'https://discord.com/channels/715806612824260640/123456789000000014',
        account_name: "paginationtest#{i}"
      )
    end
    visit_with_auth "/companies/#{companies(:company1).id}/users?target=all", 'kimura'
    assert companies(:company1).users.count >= 25
    assert_selector 'nav.pagination', count: 2
  end
end
