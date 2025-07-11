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
    @reply_deadline_days = 6
  end

  def test_default
    product = products(:product6)
    render_inline(Products::ProductComponent.new(
                    product:,
                    is_mentor: @is_mentor,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id,
                    reply_deadline_days: @reply_deadline_days
                  ))

    assert_text product.user.long_name
    assert_text "#{product.practice.title}の提出物"
    assert_text I18n.l(product.published_at)
    assert_text I18n.l(product.updated_at)
  end

  def test_render_user_icon_when_display_user_icon_is_true
    product = products(:product6)
    render_inline(Products::ProductComponent.new(
                    product:,
                    is_mentor: @is_mentor,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id,
                    reply_deadline_days: @reply_deadline_days,
                    display_user_icon: true
                  ))

    assert_selector "img.card-list-item__user-icon[src*='#{product.user.avatar_url}']"
  end

  def test_does_not_render_user_icon_when_display_user_icon_is_false
    product = products(:product6)
    render_inline(Products::ProductComponent.new(
                    product:,
                    is_mentor: @is_mentor,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id,
                    reply_deadline_days: @reply_deadline_days,
                    display_user_icon: false
                  ))

    assert_no_selector "img.card-list-item__user-icon[src*='#{product.user.avatar_url}']"
  end

  def test_render_wip_badge_when_product_is_wip
    wip_product = products(:product5)
    render_inline(Products::ProductComponent.new(
                    product: wip_product,
                    is_mentor: @is_mentor,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id,
                    reply_deadline_days: @reply_deadline_days
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
                    current_user_id: @current_user_id,
                    reply_deadline_days: @reply_deadline_days
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
                    current_user_id: @current_user_id,
                    reply_deadline_days: @reply_deadline_days
                  ))

    assert_selector '.a-meta', text: 'コメント（1）'
    assert_selector "img.a-user-icon[title='komagata (Komagata Masaki): 管理者、メンター']"
  end

  def test_render_published_at_when_product_is_published
    published_product = products(:product6)
    render_inline(Products::ProductComponent.new(
                    product: published_product,
                    is_mentor: @is_mentor,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id,
                    reply_deadline_days: @reply_deadline_days
                  ))

    assert_selector '.a-meta', text: '提出'
    assert_text I18n.l(published_product.published_at)
  end

  def test_render_created_at_when_product_is_not_published
    unpublished_product = products(:product66)
    render_inline(Products::ProductComponent.new(
                    product: unpublished_product,
                    is_mentor: @is_mentor,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id,
                    reply_deadline_days: @reply_deadline_days
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
                    current_user_id: @current_user_id,
                    reply_deadline_days: @reply_deadline_days
                  ))

    assert_selector '.a-meta', text: '研修終了日'

    render_inline(Products::ProductComponent.new(
                    product: trainee_product,
                    is_mentor: false,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id,
                    reply_deadline_days: @reply_deadline_days
                  ))

    assert_selector '.a-meta', text: '研修終了日'
  end

  def test_does_not_render_training_remaining_days_when_user_is_not_mentor_or_admin_and_product_user_is_trainee
    trainee_product = products(:product13)
    render_inline(Products::ProductComponent.new(
                    product: trainee_product,
                    is_mentor: false,
                    is_admin: false,
                    current_user_id: @current_user_id,
                    reply_deadline_days: @reply_deadline_days
                  ))

    assert_no_selector '.a-meta', text: '研修終了日'
  end

  def test_does_not_render_training_remaining_days_when_product_user_is_not_trainee
    non_trainee_product = products(:product13)
    render_inline(Products::ProductComponent.new(
                    product: non_trainee_product,
                    is_mentor: false,
                    is_admin: false,
                    current_user_id: @current_user_id,
                    reply_deadline_days: @reply_deadline_days
                  ))

    assert_no_selector '.a-meta', text: '研修終了日'
  end

  def test_render_product_checker_when_user_is_mentor_and_no_checks
    product = products(:product6)
    render_inline(Products::ProductComponent.new(
                    product:,
                    is_mentor: @is_mentor,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id,
                    reply_deadline_days: @reply_deadline_days
                  ))

    assert_selector '.card-list-item__assignee'
  end

  def test_does_not_render_product_checker_when_user_is_not_mentor
    product = products(:product6)
    render_inline(Products::ProductComponent.new(
                    product:,
                    is_mentor: false,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id,
                    reply_deadline_days: @reply_deadline_days
                  ))

    assert_no_selector '.card-list-item__assignee'
  end

  def test_render_approval_stamp_and_does_not_render_product_checker_when_there_are_checks
    checked_product = products(:product3)
    render_inline(Products::ProductComponent.new(
                    product: checked_product,
                    is_mentor: @is_mentor,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id,
                    reply_deadline_days: @reply_deadline_days
                  ))

    assert_selector '.stamp.stamp-approve' do
      assert_text '合格'
      assert_text I18n.l(Time.zone.today, format: :short)
      assert_text 'komagata'
    end

    assert_no_selector '.card-list-item__assignee'
  end

  def test_does_not_render_approval_stamp_when_no_checks
    non_checked_product = products(:product6)
    render_inline(Products::ProductComponent.new(
                    product: non_checked_product,
                    is_mentor: @is_mentor,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id,
                    reply_deadline_days: @reply_deadline_days
                  ))

    assert_no_selector '.stamp.stamp-approve'
  end

  def test_render_until_next_elapsed_days_when_display_until_next_elapsed_days_is_true
    product = products(:product70)
    render_inline(Products::ProductComponent.new(
                    product:,
                    is_mentor: @is_mentor,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id,
                    reply_deadline_days: @reply_deadline_days,
                    display_until_next_elapsed_days: true
                  ))

    assert_selector '.a-meta__label' do
      assert_text '次の経過日数まで'
      assert_text '約7時間'
    end
  end

  def test_does_not_render_until_next_elapsed_days_when_display_until_next_elapsed_days_is_false
    product = products(:product70)
    render_inline(Products::ProductComponent.new(
                    product:,
                    is_mentor: @is_mentor,
                    is_admin: @is_admin,
                    current_user_id: @current_user_id,
                    reply_deadline_days: @reply_deadline_days,
                    display_until_next_elapsed_days: false
                  ))

    assert_no_selector '.a-meta__label', text: '次の経過日数まで'
  end
end
