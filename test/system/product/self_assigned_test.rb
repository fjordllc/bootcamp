# frozen_string_literal: true

require 'application_system_test_case'

class Product::SelfAssignedTest < ApplicationSystemTestCase
  test 'non-staff user can not see listing self-assigned products' do
    visit_with_auth '/products/self_assigned', 'hatsuno'
    assert_text '管理者・アドバイザー・メンターとしてログインしてください'
  end

  test 'advisor can not see listing self-assigned products' do
    visit_with_auth '/products', 'advijirou'
    assert_no_link '自分の担当'
  end

  test 'mentor can see a button to open to open all self-assigned products' do
    checker = users(:komagata)
    Product.create!(
      body: 'test',
      user: users(:kimura),
      practice: practices(:practice5),
      checker_id: checker.id
    )
    visit_with_auth '/products/self_assigned', 'komagata'
    assert_button '自分の担当の提出物を一括で開く'
  end

  test 'click on open all self-assigned submissions button' do
    checker = users(:komagata)
    Product.create!(
      body: '自分の担当の提出物です。',
      user: users(:kimura),
      practice: practices(:practice5),
      checker_id: checker.id
    )
    visit_with_auth '/products/self_assigned', 'komagata'

    click_button '自分の担当の提出物を一括で開く'

    within_window(windows.last) do
      assert_text '自分の担当の提出物です。'
    end
  end

  test 'display products on self assigned tab' do
    oldest_product = products(:product15)
    newest_product = products(:product64)

    visit_with_auth '/products/self_assigned', 'machida'

    assert_equal 'OS X Mountain Lionをクリーンインストールする', oldest_product.practice.title
    assert_equal 'sshdをインストールする', newest_product.practice.title
  end

  test 'not display products in listing self-assigned if self-assigned products all checked' do
    product = products(:product3)
    checker = users(:komagata)
    product.checker_id = checker.id
    product.save
    visit_with_auth '/products/self_assigned?target=self_assigned_all', 'komagata'
    assert_text '提出物はありません'
  end

  test 'display no replied products if click on self-assigned-tab' do
    checker = users(:mentormentaro)
    practice = practices(:practice5)
    user = users(:kimura)
    Product.create!(
      body: 'test',
      user:,
      practice:,
      checker_id: checker.id
    )
    visit_with_auth '/products/self_assigned', 'mentormentaro'
    titles = all('.card-list-item-title__title').map { |t| t.text.gsub('★', '') }
    names = all('.card-list-item-meta .a-user-name').map(&:text)
    assert_equal ["#{practice.title}の提出物"], titles
    assert_equal [user.login_name], names
  end

  test 'display no replied products if click on no-replied-button' do
    checker = users(:mentormentaro)
    practice = practices(:practice5)
    user = users(:kimura)
    Product.create!(
      body: 'test',
      user:,
      practice:,
      checker_id: checker.id
    )
    visit_with_auth '/products/self_assigned?target=self_assigned_no_replied', 'mentormentaro'
    titles = all('.card-list-item-title__title').map { |t| t.text.gsub('★', '') }
    names = all('.card-list-item-meta .a-user-name').map(&:text)
    assert_equal ["#{practice.title}の提出物"], titles
    assert_equal [user.login_name], names
  end

  test 'display replied products if click on self_assigned_all-button' do
    checker = users(:mentormentaro)
    practice = practices(:practice5)
    user = users(:kimura)
    product = Product.create!(
      body: 'test',
      user:,
      practice:,
      checker_id: checker.id
    )
    visit_with_auth "/products/#{product.id}", 'mentormentaro'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    click_button 'コメントする'
    visit_with_auth '/products/self_assigned?target=self_assigned_all', 'mentormentaro'
    titles = all('.card-list-item-title__title').map { |t| t.text.gsub('★', '') }
    names = all('.card-list-item-meta .a-user-name').map(&:text)
    assert_equal ["#{practice.title}の提出物"], titles
    assert_equal [user.login_name], names
    visit_with_auth '/products/self_assigned?target=self_assigned_no_replied', 'mentormentaro'
    assert_text '未返信の担当提出物はありません'
  end
end
