# frozen_string_literal: true

require 'application_system_test_case'

class LearningStatusTest < ApplicationSystemTestCase
  test 'learning status changes to submitted after the mentor cancels the confirmation' do
    product = Product.create!(
      body: '直接確認する提出物',
      user: users(:kimuramitai),
      practice: practices(:practice1)
    )
    visit_with_auth "/products/#{product.id}", 'machida'
    click_button '担当する'
    click_button '提出物を確認'
    click_button '提出物の確認を取り消す'
    visit_with_auth "/products/#{product.id}", 'kimuramitai'
    assert_no_selector 'h2', text: 'このプラクティスは修了しました🎉'
  end

  test 'learning status changes to submitted after the mentor cancels the confirmation with comment' do
    product = Product.create!(
      body: 'コメントで確認する提出物',
      user: users(:kimuramitai),
      practice: practices(:practice1)
    )
    visit_with_auth "/products/#{product.id}", 'machida'
    click_button '担当する'
    fill_in('new_comment[description]', with: 'LGTMです。')
    accept_alert do
      click_button '確認OKにする'
    end
    click_button '提出物の確認を取り消す'
    visit_with_auth "/products/#{product.id}", 'kimuramitai'
    assert_no_selector 'h2', text: 'このプラクティスは修了しました🎉'
  end
end
