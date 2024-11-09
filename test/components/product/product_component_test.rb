# frozen_string_literal: true

require 'test_helper'
require 'supports/decorator_helper'

class Products::ProductComponentTest < ViewComponent::TestCase
  include DecoratorHelper

  def setup
    auto_decorate(User)
    @current_user_id = users(:komagata).id
    @is_mentor = true
    @is_admin = true
  end

  def test_default
    unassigned_product = products(:product6)
    render_inline(Products::ProductComponent.new(
                    product: unassigned_product,
                    is_mentor: @is_mentor,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id
                  ))

    assert_text unassigned_product.user.long_name
    assert_text "#{unassigned_product.practice.title}の提出物"
    assert_text I18n.l(unassigned_product.published_at)
    assert_text I18n.l(unassigned_product.updated_at)
  end

  def test_render_user_icon_when_display_user_icon_is_true
    unassigned_product = products(:product6)
    render_inline(Products::ProductComponent.new(
                    product: unassigned_product,
                    is_mentor: @is_mentor,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id,
                    display_user_icon: true
                  ))

    assert_selector "img.card-list-item__user-icon[src*='#{unassigned_product.user.avatar_url}']"
  end

  def test_does_not_render_user_icon_when_display_user_icon_is_false
    unassigned_product = products(:product6)
    render_inline(Products::ProductComponent.new(
                    product: unassigned_product,
                    is_mentor: @is_mentor,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id,
                    display_user_icon: false
                  ))

    assert_no_selector "img.card-list-item__user-icon[src*='#{unassigned_product.user.avatar_url}']"
  end

  def test_render_wip_badge_when_product_is_wip
    wip_product = products(:product5)
    render_inline(Products::ProductComponent.new(
                    product: wip_product,
                    is_mentor: @is_mentor,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id
                  ))

    assert_selector '.a-list-item-badge.is-wip'
    assert_text 'WIP'
    assert_text '提出物作成中'
  end

  def test_does_not_render_wip_badge_when_product_is_not_wip
    non_wip_product = products(:product6)
    render_inline(Products::ProductComponent.new(
                    product: non_wip_product,
                    is_mentor: @is_mentor,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id
                  ))

    assert_no_selector '.a-list-item-badge.is-wip'
    assert_no_text 'WIP'
    assert_no_text '提出物作成中'
  end

  def test_render_comments_count_and_user_icon_when_there_are_comments
    commented_product = products(:product10)
    render_inline(Products::ProductComponent.new(
                    product: commented_product,
                    is_mentor: @is_mentor,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id
                  ))

    assert_selector '.a-meta', text: 'コメント（1）'
    assert_selector "img.a-user-icon[title='komagata (Komagata Masaki): 管理者、メンター']"
  end

  def test_render_published_at_when_product_is_published
    unassigned_product = products(:product6)
    render_inline(Products::ProductComponent.new(
                    product: unassigned_product,
                    is_mentor: @is_mentor,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id
                  ))

    assert_selector '.a-meta', text: '提出'
    assert_text I18n.l(unassigned_product.published_at)
  end

  def test_render_created_at_when_product_is_not_published
    unpublished_product = products(:product66)
    render_inline(Products::ProductComponent.new(
                    product: unpublished_product,
                    is_mentor: @is_mentor,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id
                  ))

    assert_selector '.a-meta', text: '提出'
    assert_text I18n.l(unpublished_product.created_at)
  end

  def test_render_training_remaining_days_when_user_is_mentor_or_admin_and_product_user_is_trainee
    trainee_product = products(:product13)
    render_inline(Products::ProductComponent.new(
                    product: trainee_product,
                    is_mentor: @is_mentor,
                    is_admin: false,
                    current_user_id: @current_user_id
                  ))

    assert_selector '.a-meta', text: '研修終了日'

    render_inline(Products::ProductComponent.new(
                    product: trainee_product,
                    is_mentor: false,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id
                  ))

    assert_selector '.a-meta', text: '研修終了日'
  end

  def test_does_not_render_training_remaining_days_when_user_is_not_mentor_or_admin_and_product_user_is_trainee
    trainee_product = products(:product13)
    render_inline(Products::ProductComponent.new(
                    product: trainee_product,
                    is_mentor: false,
                    is_admin: false,
                    current_user_id: @current_user_id
                  ))

    assert_no_selector '.a-meta', text: '研修終了日'
  end

  def test_does_not_render_training_remaining_days_when_product_user_is_not_trainee
    non_trainee_product = products(:product13)
    render_inline(Products::ProductComponent.new(
                    product: non_trainee_product,
                    is_mentor: false,
                    is_admin: false,
                    current_user_id: @current_user_id
                  ))

    assert_no_selector '.a-meta', text: '研修終了日'
  end

  def test_render_product_checker_when_user_is_mentor_and_no_checks
    unassigned_product = products(:product6)
    render_inline(Products::ProductComponent.new(
                    product: unassigned_product,
                    is_mentor: @is_mentor,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id
                  ))

    assert_selector '.card-list-item__assignee'
  end

  def test_does_not_render_product_checker_when_user_is_not_mentor
    unassigned_product = products(:product6)
    render_inline(Products::ProductComponent.new(
                    product: unassigned_product,
                    is_mentor: false,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id
                  ))

    assert_no_selector '.card-list-item__assignee'
  end

  def test_render_approval_stamp_and_does_not_render_product_checker_when_there_are_checks
    checked_product = products(:product3)
    render_inline(Products::ProductComponent.new(
                    product: checked_product,
                    is_mentor: @is_mentor,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id
                  ))

    assert_selector '.stamp.stamp-approve', text: '確認済'
    assert_no_selector '.card-list-item__assignee'
  end

  def test_does_not_render_approval_stamp_when_no_checks
    non_checked_product = products(:product6)
    render_inline(Products::ProductComponent.new(
                    product: non_checked_product,
                    is_mentor: @is_mentor,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id
                  ))

    assert_no_selector '.stamp.stamp-approve', text: '確認済'
  end
end
