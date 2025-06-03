# frozen_string_literal: true

require 'application_system_test_case'

class ProductCheckingTest < ApplicationSystemTestCase
  test 'setting checker on show page' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    click_button '担当する'
    assert_button '担当から外れる'
  end

  test 'unsetting checker on show page' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    click_button '担当する'
    click_button '担当から外れる'
    assert_button '担当する'
  end

  test 'hide checker button at product checked' do
    visit_with_auth "/products/#{products(:product1).id}", 'machida'
    assert_button '担当する'
    click_button '提出物を合格にする'
    assert_no_button '担当する'
    assert_no_button '担当から外れる'
  end

  test 'change checker on edit page' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    click_button '担当する'
    click_link '内容修正'
    select 'machida', from: 'product_checker_id'
    click_button '提出する'
    assert_text 'machida'
  end

  test 'setting checker' do
    visit_with_auth products_path, 'komagata'
    click_button '担当する', match: :first
    assert_button '担当から外れる'
  end

  test 'unsetting checker' do
    visit_with_auth products_path, 'komagata'
    click_button '担当する', match: :first
    click_button '担当から外れる', match: :first
    assert_button '担当する'
  end

  test 'add comment setting checker' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    fill_in 'new_comment[description]', with: 'コメントしたら担当になるテスト'
    click_button 'コメントする'
    accept_alert '提出物の担当になりました。'
    assert_text 'コメントしたら担当になるテスト'
    visit current_path
    assert_text '担当から外れる'
    assert_no_text '担当する'
  end

  test 'can see unassigned-tab' do
    visit_with_auth products_path, 'komagata'
    assert find('.page-tabs__item-link', text: '未アサイン')
  end

  test 'can access unassigned products page after click unassigned-tab' do
    visit_with_auth products_path, 'komagata'
    find('.page-tabs__item-link', text: '未アサイン').click
    assert find('h2.page-header__title', text: '提出物')
  end

  test 'show unassigned products counter and can change counter after click assignee-button on unassigned-tab' do
    visit_with_auth products_path, 'komagata'
    unassigned_tab = find('#test-unassigned-tab')
    initial_counter = find('#test-unassigned-counter').text

    assignee_buttons = all('.a-button.is-block.is-secondary.is-sm', text: '担当する')
    assignee_buttons.first.click
    assert_text '担当から外れる'

    unassigned_tab.click
    operated_counter = find('#test-unassigned-counter').text
    assert_not_equal initial_counter, operated_counter
  end
end
