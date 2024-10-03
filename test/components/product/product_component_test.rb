# frozen_string_literal: true

require 'test_helper'
require 'supports/decorator_helper'

class Products::ProductComponentTest < ViewComponent::TestCase
  def setup
    DecoratorHelper.auto_decorate(User)
    @current_user = users(:komagata)
    @is_mentor = true
  end

  def test_default
    unassigned_product = products(:product6)
    render_inline(Products::ProductComponent.new(
                    product: unassigned_product,
                    is_mentor: @is_mentor,
                    current_user_id: @current_user_id
                  ))

    assert_selector '.is-graduate'
    assert_selector '.card-list-item__user-icon'
    assert_text unassigned_product.user.long_name
    assert_text "#{unassigned_product.practice.title}の提出物"
    assert_text I18n.l(unassigned_product.published_at)
    assert_text I18n.l(unassigned_product.updated_at)
  end

  def test_render_wip_badge_when_product_is_wip
    wip_product = products(:product5)
    render_inline(Products::ProductComponent.new(
                    product: wip_product,
                    is_mentor: @is_mentor,
                    current_user_id: @current_user_id
                  ))

    assert_selector '.a-list-item-badge.is-wip'
    assert_text 'WIP'
    assert_text '提出物作成中'
  end

  def test_render_published_at_when_product_is_published
    unassigned_product = products(:product6)
    render_inline(Products::ProductComponent.new(
                    product: unassigned_product,
                    is_mentor: @is_mentor,
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
                    current_user_id: @current_user_id
                  ))

    assert_selector '.a-meta', text: '提出'
    assert_text I18n.l(unpublished_product.created_at)
  end
end
