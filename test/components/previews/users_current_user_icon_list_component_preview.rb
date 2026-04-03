# frozen_string_literal: true

class UsersCurrentUserIconListComponentPreview < ViewComponent::Preview
  def default
    users = [
      mock_user(name: 'yamada', role: 'student', online: true),
      mock_user(name: 'tanaka', role: 'mentor', online: true),
      mock_user(name: 'suzuki', role: 'student', online: false)
    ]

    render(Users::CurrentUserIconListComponent.new(users: users))
  end

  def with_many_users
    users = (1..10).map do |i|
      mock_user(
        name: "user#{i}",
        role: i.even? ? 'student' : 'mentor',
        online: [true, false].sample
      )
    end

    render(Users::CurrentUserIconListComponent.new(users: users))
  end

  private

  def mock_user(name:, role:, online:)
    user = OpenStruct.new(
      id: rand(1000),
      login_name: name,
      name: name,
      primary_role: role,
      avatar_url: 'https://via.placeholder.com/40',
      icon_title: name,
      online?: online,
      user_icon_frame_class: "a-user-role is-#{role}",
      updated_at: online ? 5.minutes.ago : 2.hours.ago
    )
    user.define_singleton_method(:icon_classes) { |image_class| ['a-user-icon', image_class].compact.join(' ') }
    user.define_singleton_method(:to_param) { login_name }
    user.define_singleton_method(:persisted?) { true }
    user.define_singleton_method(:model_name) { OpenStruct.new(route_key: 'users', singular_route_key: 'user') }
    user
  end
end
