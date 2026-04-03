# frozen_string_literal: true

class ProductsProductComponentPreview < ViewComponent::Preview
  def default
    product = mock_product

    render(Products::ProductComponent.new(
             product: product,
             is_mentor: false,
             is_admin: false,
             current_user_id: 1,
             reply_deadline_days: 7
           ))
  end

  def with_mentor_view
    product = mock_product

    render(Products::ProductComponent.new(
             product: product,
             is_mentor: true,
             is_admin: false,
             current_user_id: 2,
             reply_deadline_days: 7
           ))
  end

  def wip_product
    product = mock_product(wip: true)

    render(Products::ProductComponent.new(
             product: product,
             is_mentor: false,
             is_admin: false,
             current_user_id: 1,
             reply_deadline_days: 7
           ))
  end

  def with_checker
    product = mock_product(with_checker: true)

    render(Products::ProductComponent.new(
             product: product,
             is_mentor: true,
             is_admin: false,
             current_user_id: 2,
             reply_deadline_days: 7
           ))
  end

  def with_elapsed_days_display
    product = mock_product(published_days_ago: 5)

    render(Products::ProductComponent.new(
             product: product,
             is_mentor: true,
             is_admin: false,
             current_user_id: 2,
             reply_deadline_days: 7,
             display_until_next_elapsed_days: true
           ))
  end

  private

  def mock_user(name: 'yamada', role: 'student')
    user = OpenStruct.new(
      id: 1,
      login_name: name,
      name: name,
      name_kana: 'ヤマダ',
      long_name: "#{name} (ヤマダ)",
      primary_role: role,
      joining_status: 'active',
      avatar_url: 'https://via.placeholder.com/40',
      icon_title: name,
      user_icon_frame_class: "a-user-role is-#{role}",
      training_ends_on: nil,
      training_remaining_days: nil
    )
    user.define_singleton_method(:icon_classes) { |image_class| ['a-user-icon', image_class].compact.join(' ') }
    user.define_singleton_method(:to_param) { name }
    user.define_singleton_method(:persisted?) { true }
    user.define_singleton_method(:model_name) { OpenStruct.new(route_key: 'users', singular_route_key: 'user') }
    user
  end

  def mock_checker
    user = OpenStruct.new(
      id: 2,
      login_name: 'mentor',
      name: 'メンター',
      primary_role: 'mentor',
      avatar_url: 'https://via.placeholder.com/40',
      icon_title: 'メンター',
      user_icon_frame_class: 'a-user-role is-mentor'
    )
    user.define_singleton_method(:icon_classes) { |image_class| ['a-user-icon', image_class].compact.join(' ') }
    user.define_singleton_method(:to_param) { 'mentor' }
    user.define_singleton_method(:persisted?) { true }
    user.define_singleton_method(:model_name) { OpenStruct.new(route_key: 'users', singular_route_key: 'user') }
    user
  end

  def mock_checks(with_checker)
    return [] unless with_checker
    
    check_user = OpenStruct.new(
      id: 3, login_name: 'checker_user', name: 'チェッカー',
      primary_role: 'mentor', avatar_url: 'https://via.placeholder.com/40',
      icon_title: 'チェッカー', user_icon_frame_class: 'a-user-role is-mentor'
    )
    check_user.define_singleton_method(:icon_classes) { |image_class| ['a-user-icon', image_class].compact.join(' ') }
    check_user.define_singleton_method(:to_param) { 'checker_user' }
    check_user.define_singleton_method(:persisted?) { true }
    check_user.define_singleton_method(:model_name) { OpenStruct.new(route_key: 'users', singular_route_key: 'user') }
    
    [OpenStruct.new(created_at: 1.day.ago, user: check_user)]
  end

  def mock_product(wip: false, with_checker: false, published_days_ago: 2)
    user = mock_user
    checker = with_checker ? mock_checker : nil
    published_at = published_days_ago.days.ago
    comments = [OpenStruct.new(id: 1, user: user, body: 'コメントです', created_at: 1.day.ago)]

    OpenStruct.new(
      id: 1, wip?: wip, user: user,
      practice: OpenStruct.new(id: 1, title: 'Rubyの基礎を理解する'),
      comments: comments,
      commented_users: OpenStruct.new(distinct: [user]),
      published_at: published_at, created_at: published_at, updated_at: Time.current,
      checker_id: checker&.id, checker: checker,
      checks: mock_checks(with_checker),
      self_last_commented_at: 1.day.ago, mentor_last_commented_at: nil
    )
  end
end
