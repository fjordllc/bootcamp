# frozen_string_literal: true

require 'application_system_test_case'

class ProductCommentsTest < ApplicationSystemTestCase
  test 'post new comment for product' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    click_button 'コメントする'
    accept_alert '提出物の担当になりました。'
    assert_text 'test'
    assert_text 'Watch中'
  end

  test 'check preview for product' do
    visit_with_auth "/products/#{products(:product2).id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: "1\n2\n3\n4\n5\n6\n7\n8\n9")
    end
    all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text "1\n2\n3\n4\n5\n6\n7\n8\n9"
  end

  test 'text change "see more comments" button by remaining comment amount' do
    visit_with_auth product_path(users(:hatsuno).products.first.id), 'komagata'

    # Wait for comments to load completely
    # Wait for comments section to load
    if has_css?('#comments.loaded')
      find('#comments.loaded')
    else
      # Fallback: wait for comments section to be present
      find('#comments')
    end

    # Wait for the button to appear with correct text
    assert_selector '.a-button.is-lg.is-text.is-block', text: '前のコメント（ 8 / 12 ）'

    find('.a-button.is-lg.is-text.is-block').click

    # Wait for button text to update
    assert_selector '.a-button.is-lg.is-text.is-block', text: '前のコメント（ 4 ）'

    find('.a-button.is-lg.is-text.is-block').click

    # Wait for button to disappear
    assert_no_selector '.a-button.is-lg.is-text.is-block'
  end

  test 'comments added 8 or within the last 8' do
    visit_with_auth product_path(users(:hatsuno).products.first.id), 'komagata'

    # Wait for comments to load completely
    # Wait for comments section to load
    if has_css?('#comments.loaded')
      find('#comments.loaded')
    else
      # Fallback: wait for comments section to be present
      find('#comments')
    end

    # Wait for all comments to be rendered
    assert_selector '.thread-comment', minimum: 1

    assert_text '提出物のコメント20です'
    assert_text '提出物のコメント13です。'
    assert_no_text '提出物のコメント12です。'

    find('.a-button.is-lg.is-text.is-block').click

    # Wait for new comments to load
    assert_text '提出物のコメント12です。'

    assert_text '提出物のコメント20です'
    assert_text '提出物のコメント5です。'
    assert_no_text '提出物のコメント4です。'

    find('.a-button.is-lg.is-text.is-block').click

    # Wait for all comments to load
    assert_text '提出物のコメント4です。'

    assert_text '提出物のコメント20です'
    assert_text '提出物のコメント1です。'
  end

  test 'when mentor confirm a product with comment' do
    unconfirmed_product = products(:product1)
    # Ensure the product is unassigned
    unconfirmed_product.update!(checker_id: nil)
    visit_with_auth product_url(unconfirmed_product), 'machida'

    # Wait for page to fully load
    # Wait for comments section to load
    if has_css?('#comments.loaded')
      find('#comments.loaded')
    else
      # Fallback: wait for comments section to be present
      find('#comments')
    end

    click_button '担当する'
    assert_button '担当から外れる'

    accept_confirm do
      fill_in 'new_comment[description]', with: 'comment test'
      click_button '合格にする'
    end

    # Wait for comment to be displayed first
    assert_selector '.thread-comment__description', text: 'comment test'

    # Check that product is confirmed in database
    assert unconfirmed_product.reload.checked?
  end

  test 'when mentor confirm unassigned product with comment' do
    unassigned_product = products(:product1)
    # Ensure the product is unassigned
    unassigned_product.update!(checker_id: nil)
    visit_with_auth product_url(unassigned_product), 'machida'

    # Wait for page to fully load
    # Wait for comments section to load
    if has_css?('#comments.loaded')
      find('#comments.loaded')
    else
      # Fallback: wait for comments section to be present
      find('#comments')
    end

    # Wait for page content to be fully loaded before checking for button
    assert_selector '.page-content'

    # Wait for Vue.js component to initialize and render the product checker button
    assert_selector '#js-check', wait: 10

    # Wait for the product checker button (担当する) to become available and enabled
    assert_button '担当する', wait: 10

    accept_confirm do
      fill_in 'new_comment[description]', with: 'comment test'
      click_button '合格にする'
    end

    # Wait for comment to be displayed first
    assert_selector '.thread-comment__description', text: 'comment test'

    # Check that product is confirmed in database
    assert unassigned_product.reload.checked?
  end
end
