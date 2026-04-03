# frozen_string_literal: true

class ProductsProductComponentPreview < ViewComponent::Preview
  include PreviewHelper

  def default
    render(Products::ProductComponent.new(
             product: mock_product,
             is_mentor: false, is_admin: false,
             current_user_id: 1, reply_deadline_days: 7
           ))
  end

  def with_mentor_view
    render(Products::ProductComponent.new(
             product: mock_product(with_checker: true),
             is_mentor: true, is_admin: false,
             current_user_id: 2, reply_deadline_days: 7
           ))
  end

  def wip_product
    render(Products::ProductComponent.new(
             product: mock_product(wip: true),
             is_mentor: false, is_admin: false,
             current_user_id: 1, reply_deadline_days: 7,
             display_until_next_elapsed_days: true
           ))
  end

  private

  def mock_practice
    practice = OpenStruct.new(id: 1, title: 'Rubyの基礎を理解する')
    practice.define_singleton_method(:to_param) { '1' }
    practice.define_singleton_method(:persisted?) { true }
    practice.define_singleton_method(:model_name) { ActiveModel::Name.new(nil, nil, 'Practice') }
    practice
  end

  def mock_product(wip: false, with_checker: false, published_days_ago: 2)
    user = build_mock_user(name_kana: 'ヤマダ', long_name: 'yamada (ヤマダ)')
    checker = with_checker ? build_mock_user(id: 2, login_name: 'mentor', name: 'メンター', primary_role: 'mentor', icon_title: 'メンター') : nil
    published_at = published_days_ago.days.ago
    comments = [OpenStruct.new(id: 1, user: user, body: 'コメントです', created_at: 1.day.ago)]
    checks = if with_checker
               [OpenStruct.new(created_at: 1.day.ago,
                               user: build_mock_user(id: 3, login_name: 'checker', name: 'チェッカー',
                                                     primary_role: 'mentor', icon_title: 'チェッカー'))]
             else
               []
             end

    product = OpenStruct.new(
      id: 1, wip?: wip, user: user, practice: mock_practice,
      comments: comments, commented_users: OpenStruct.new(distinct: [user]),
      published_at: published_at, created_at: published_at, updated_at: Time.current,
      checker_id: checker&.id, checker: checker, checks: checks,
      self_last_commented_at: 1.day.ago, mentor_last_commented_at: nil
    )
    product.define_singleton_method(:to_param) { '1' }
    product.define_singleton_method(:persisted?) { true }
    product.define_singleton_method(:model_name) { ActiveModel::Name.new(nil, nil, 'Product') }
    product
  end
end
