# frozen_string_literal: true

class ProductsUserProductsComponentPreview < ViewComponent::Preview
  def default
    products = [mock_product('Rubyの基礎'), mock_product('Git入門')]
    current_user = mock_user('yamada')

    render(Products::UserProductsComponent.new(
             products: products,
             current_user: current_user,
             is_mentor: false
           ))
  end

  def empty
    current_user = mock_user('yamada')

    render(Products::UserProductsComponent.new(
             products: [],
             current_user: current_user,
             is_mentor: false
           ))
  end

  def as_mentor
    products = [mock_product('Rubyの基礎')]
    current_user = mock_user('mentor')

    render(Products::UserProductsComponent.new(
             products: products,
             current_user: current_user,
             is_mentor: true
           ))
  end

  private

  def mock_user(name)
    user = OpenStruct.new(
      id: 1,
      login_name: name,
      name: name,
      primary_role: 'student',
      joining_status: 'active',
      avatar_url: 'https://via.placeholder.com/40',
      icon_title: name,
      user_icon_frame_class: 'a-user-role is-student',
      admin?: false,
      mentor?: false,
      training_ends_on: nil,
      training_remaining_days: nil
    )
    user.define_singleton_method(:icon_classes) { |image_class| ['a-user-icon', image_class].compact.join(' ') }
    user.define_singleton_method(:to_param) { name }
    user.define_singleton_method(:persisted?) { true }
    user.define_singleton_method(:model_name) { OpenStruct.new(route_key: 'users', singular_route_key: 'user') }
    user
  end

  def mock_product(practice_title)
    user = mock_user('yamada')
    practice = OpenStruct.new(id: 1, title: practice_title)

    OpenStruct.new(
      id: rand(1..100),
      wip?: false,
      user: user,
      practice: practice,
      comments: [],
      published_at: 2.days.ago,
      created_at: 2.days.ago,
      updated_at: Time.current,
      checker_id: nil,
      checker: nil,
      checks: OpenStruct.new(last: nil)
    )
  end
end
