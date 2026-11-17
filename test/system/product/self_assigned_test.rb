# frozen_string_literal: true

require 'application_system_test_case'

class Product::SelfAssignedTest < ApplicationSystemTestCase
  test 'not display no replied wip products if click on no-replied-button' do
    mentor = users(:machida)
    product = products(:product62)
    product.update!(wip: true)

    visit_with_auth '/products/self_assigned?target=self_assigned_no_replied', mentor.login_name
    product_title_list = all('.card-list-item-title__title').map(&:text)
    assert_not_includes product_title_list, "#{product.practice.title}の提出物"
  end

  test 'not display last replied wip products by student if click on no-replied-button' do
    mentor = users(:machida)
    product = products(:product63)
    product.update(wip: true)

    Comment.create!(
      user: product.user,
      commentable: product,
      description: '提出者のコメント'
    )

    visit_with_auth '/products/self_assigned?target=self_assigned_no_replied', mentor.login_name
    product_title_list = all('.card-list-item-title__title').map(&:text)
    assert_not_includes product_title_list, "#{product.practice.title}の提出物"
  end

  test 'display replied products if click on self_assigned_all-button' do
    checker = users(:mentormentaro)
    practice = practices(:practice5)
    user = users(:kimura)
    decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
    product = Product.create!(
      body: 'test',
      user:,
      practice:,
      checker_id: checker.id
    )
    visit_with_auth "/products/#{product.id}", 'mentormentaro'
    within('.thread-comment-form__form') do
      fill_in('comment[description]', with: 'test')
    end
    click_button 'コメントする'
    visit_with_auth '/products/self_assigned?target=self_assigned_all', 'mentormentaro'
    titles = all('.card-list-item-title__title').map { |t| t.text.delete('★') }
    names = all('.card-list-item-meta .a-user-name').map(&:text)
    assert_equal ["#{practice.title}の提出物"], titles
    assert_equal [decorated_user.long_name], names
    visit_with_auth '/products/self_assigned?target=self_assigned_no_replied', 'mentormentaro'
    assert_text '未返信の担当提出物はありません'
  end

  test "not display hibernated users' products in a self assigned products list" do
    checker = users(:mentormentaro)
    unhibernated_user = users(:kimura)
    hibernated_user = users(:kyuukai)
    practice = practices(:practice5)

    Product.create!(
      body: 'test',
      user: unhibernated_user,
      practice:,
      checker_id: checker.id
    )
    Product.create!(
      body: 'test',
      user: hibernated_user,
      practice:,
      checker_id: checker.id
    )

    unhibernated_users_displayed_name = "#{unhibernated_user.login_name} (#{unhibernated_user.name_kana})"
    hibernated_users_displayed_name = "#{hibernated_user.login_name} (#{hibernated_user.name_kana})"

    visit_with_auth '/products/self_assigned?target=self_assigned_all', 'mentormentaro'
    assert_text unhibernated_users_displayed_name
    assert_no_text hibernated_users_displayed_name

    visit_with_auth '/products/self_assigned?target=self_assigned_no_replied', 'mentormentaro'
    assert_text unhibernated_users_displayed_name
    assert_no_text hibernated_users_displayed_name
  end
end
