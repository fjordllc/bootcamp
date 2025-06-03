# frozen_string_literal: true

require 'application_system_test_case'

class Home::LearningGrassTest < ApplicationSystemTestCase
  test 'show the grass for student' do
    assert users(:kimura).student?
    visit_with_auth '/', 'kimura'
    assert_selector 'h2.card-header__title', text: '学習時間'
  end

  test 'show the grass for trainee' do
    assert users(:kensyu).trainee?
    visit_with_auth '/', 'kensyu'
    assert_selector 'h2.card-header__title', text: '学習時間'
  end

  test 'not show the grass for mentor' do
    assert users(:mentormentaro).mentor?
    visit_with_auth '/', 'mentormentaro'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_selector 'h2.card-header__title', text: '学習時間'
  end

  test 'not show the grass for adviser' do
    assert users(:advijirou).adviser?
    visit_with_auth '/', 'advijirou'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_selector 'h2.card-header__title', text: '学習時間'
  end

  test 'not show the grass for admin' do
    assert users(:komagata).admin?
    visit_with_auth '/', 'komagata'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_selector 'h2.card-header__title', text: '学習時間'
  end
end
