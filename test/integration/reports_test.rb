require 'test_helper'

class ReportsTest < ActionDispatch::IntegrationTest
  def setup
    login_user 'komagata', 'testtest'
  end

  test 'equal practices order in practices and new report' do
    click_link 'プラクティス'
    practices = page.all('.category-practices-item__value.is-title')

    click_link '日報'
    click_link '日報の新規作成'
    report_practices = page.all('.select-practices__label')

    report_practices.each_with_index do|practice, i|
      assert_equal practice.text, practices[i].find('.category-practices-item__title-link').text
    end
  end

  test 'equal practices order in practices and edit report' do
    click_link 'プラクティス'
    practices = page.all('.category-practices-item__value.is-title')

    find('.global-nav-current-user__link').click
    page.all('.user-reports-item-actions__item-link').first.click
    report_practices = page.all('.select-practices__label')

    report_practices.each_with_index do|practice, i|
      assert_equal practice.text, practices[i].find('.category-practices-item__title-link').text
    end
  end
end
