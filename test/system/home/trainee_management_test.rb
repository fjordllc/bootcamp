# frozen_string_literal: true

require 'application_system_test_case'

class HomeTraineeManagementTest < ApplicationSystemTestCase
  test 'show trainee lists for adviser belonging a company' do
    visit_with_auth '/', 'senpai'
    assert_selector 'h2.card-header__title', text: '研修生'
  end

  test 'not show trainee lists for student' do
    visit_with_auth '/', 'kimura'
    assert_no_selector 'h2.card-header__title', text: '研修生'
  end

  test 'not show trainee lists for adviser when adviser does not have same company trainees' do
    visit_with_auth '/', 'advisernocolleaguetrainee'
    assert_text '現在、ユーザの企業に登録しないで株式会社は研修を利用していません。'
  end

  test 'show trainee reports to adviser belonging to the same company on dashboard' do
    visit_with_auth '/', 'senpai'
    assert_selector 'h2.card-header__title', text: '研修生の最新の日報'
  end

  test 'not show trainee reports to anyone except adviser on dashboard' do
    visit_with_auth '/', 'kimura'
    assert_no_selector 'h2.card-header__title', text: '研修生の最新の日報'
  end
end
