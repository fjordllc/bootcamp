# frozen_string_literal: true

require 'application_system_test_case'

class Check::ProductsTest < ApplicationSystemTestCase
  test 'user can see stamp' do
    visit_with_auth "/products/#{products(:product3).id}", 'kimura'
    assert_text '合格'
  end

  test 'success product checking' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    click_button '提出物を合格にする'
    assert_text '合格'
    assert has_button? '提出物の合格を取り消す'
  end

  test 'when product checked learning status to complete' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    click_button '提出物を合格にする'
    assert_text '合格'
    assert has_button? '提出物の合格を取り消す'

    visit_with_auth "/practices/#{products(:product1).practice.id}", 'mentormentaro'
    assert_text '修了しています'
  end

  test 'success product checking cancel' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    click_button '提出物を合格にする'
    click_button '提出物の合格を取り消す'
    assert has_button? '提出物を合格にする'
  end

  test 'comment and check product' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    fill_in 'new_comment[description]', with: '提出物でcomment+合格にするtest'
    page.accept_confirm do
      click_on '合格にする'
    end
    assert_text '合格'
    assert_text '提出物でcomment+合格にするtest'
  end

  test 'comment and check product by mentor' do
    visit_with_auth "/products/#{products(:product1).id}", 'mentormentaro'
    fill_in 'new_comment[description]', with: '提出物でcomment+合格にするtest'
    page.accept_confirm do
      click_on '合格にする'
    end
    assert_text '合格'
    assert_text '提出物でcomment+合格にするtest'
  end

  test 'display error message when checking confirmed product' do
    using_session :mentormentaro do
      visit_with_auth "/products/#{products(:product1).id}", 'mentormentaro'
    end

    using_session :komagata do
      visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    end

    using_session :mentormentaro do
      click_button '提出物を合格にする'
      assert_text '合格'
      sleep 1
    end

    using_session :komagata do
      click_button '提出物を合格にする'
      assert_text 'この提出物は確認済です'
    end
  end
end
