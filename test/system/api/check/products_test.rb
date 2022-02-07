# frozen_string_literal: true

require 'application_system_test_case'

class Check::ProductsTest < ApplicationSystemTestCase
  test 'user can see stamp' do
    visit_with_auth "/products/#{products(:product3).id}", 'kimura'
    assert_text '確認済'
  end

  test 'success product checking' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    click_button '提出物を確認'
    assert_text '確認済'
    assert has_button? '提出物の確認を取り消す'
  end

  test 'when product checked learning status to complete' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    click_button '提出物を確認'
    assert_text '確認済'
    assert has_button? '提出物の確認を取り消す'

    visit_with_auth "/practices/#{products(:product1).practice.id}", 'mentormentaro'
    assert_text '完了しています'
  end

  test 'success product checking cancel' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    click_button '提出物を確認'
    click_button '提出物の確認を取り消す'
    assert_no_text '確認済'
    assert has_button? '提出物を確認'
  end

  test 'comment and check product' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    fill_in 'new_comment[description]', with: '提出物でcomment+確認OKにするtest'
    page.accept_confirm do
      click_on '確認OKにする'
    end
    assert_text '確認済'
    assert_text '提出物でcomment+確認OKにするtest'
  end
end
