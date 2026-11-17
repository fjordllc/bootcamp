# frozen_string_literal: true

require 'browserless_system_test_case'

class WelcomeBrowserlessTest < BrowserlessSystemTestCase
  test 'profile X links use x.com' do
    user = users(:komagata)
    visit '/welcome'

    assert_selector "a.lp-mentor__sns-item-link[href='https://x.com/#{user.twitter_account}'] i.fa-x-twitter", visible: :all
  end

  test '6 articles with a specific tag are displayed in order of published_at' do
    visit '/welcome'
    article_dates = all('.articles-item__published-at').map(&:text)
    expected_dates = [
      '2024年02月07日(水) 09:00',
      '2024年02月06日(火) 09:00',
      '2024年02月05日(月) 09:00',
      '2024年02月04日(日) 09:00',
      '2024年02月03日(土) 09:00',
      '2024年02月02日(金) 09:00'
    ]
    assert_equal expected_dates, article_dates
  end
end
