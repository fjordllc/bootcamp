# frozen_string_literal: true

require 'application_system_test_case'

class ProductMentorFeaturesTest < ApplicationSystemTestCase
  test 'mentors can see block for mentors' do
    visit_with_auth "/products/#{products(:product2).id}", 'mentormentaro'
    assert_text '直近の日報'
    assert_text 'ユーザー情報'
    assert_text 'ユーザーメモ'
    assert_selector '#side-tabs-nav-4', text: '提出物'
  end

  test 'students can not see block for mentors' do
    visit_with_auth "/products/#{products(:product2).id}", 'hatsuno'
    assert_no_text '直近の日報'
    assert_no_text 'プラクティスメモ'
    assert_no_text 'ユーザーメモ'
    assert_no_selector '#side-tabs-nav-4', text: '提出物'
  end

  test 'display recently reports' do
    visit_with_auth "/products/#{products(:product1).id}", 'mentormentaro'
    within first('.side-tabs .card-list-item') do
      assert_selector 'img[alt="happy"]'
      assert_text '1時間だけ学習'
    end
  end

  test 'display the user memos after click on user-memos tab' do
    visit_with_auth "/products/#{products(:product2).id}", 'komagata'
    find('#side-tabs-nav-2').click
    assert_text 'kimuraさんのメモ'
  end

  test 'can cancel editing of user-memos' do
    visit_with_auth "/products/#{products(:product2).id}", 'komagata'
    find('#side-tabs-nav-2').click
    click_button '編集'
    fill_in 'js-user-mentor-memo', with: '編集はできないはずです。'
    click_button 'キャンセル'
    assert_no_text '編集はできないはずです。'
    assert_text 'kimuraさんのメモ'
  end

  test 'can preview editing of user-memos' do
    visit_with_auth "/products/#{products(:product2).id}", 'komagata'
    find('#side-tabs-nav-2').click
    assert_text 'kimuraさんのメモ'
    click_button '編集'
    fill_in 'js-user-mentor-memo', with: 'プレビューができます。'
    find('.form-tabs__tab', text: 'プレビュー').click
    assert_text 'プレビューができます。'
  end

  test 'can update user-memos' do
    visit_with_auth "/products/#{products(:product2).id}", 'komagata'
    find('#side-tabs-nav-2').click
    click_button '編集'
    fill_in 'js-user-mentor-memo', with: '編集後のユーザーメモです。'
    click_button '保存する'
  end

  test 'display a list of products in side-column' do
    user = users(:kimura)
    visit_with_auth "/products/#{products(:product2).id}", 'mentormentaro'
    page.find('#side-tabs-nav-4').click
    products = user.products.not_wip
    products.each do |product|
      assert_text "#{product.practice.title}の提出物"
    end
  end

  test 'hide user icon from recent reports in product show' do
    visit_with_auth "/products/#{products(:product2).id}", 'komagata'
    assert_no_selector('.card-list-item__user')
  end

  test 'product show without recent reports' do
    visit_with_auth "/products/#{products(:product69).id}", 'komagata'
    assert_text '日報はまだありません。'
  end

  test 'display the skip practices after click on user-info tab' do
    visit_with_auth "/products/#{products(:product13).id}", 'komagata'
    find('#side-tabs-nav-3').click
    assert_text 'スキップするプラクティス一覧'
    assert_text 'Linuxのファイル操作の基礎を覚える'
    assert_text 'viのチュートリアルをやる'
  end
end
