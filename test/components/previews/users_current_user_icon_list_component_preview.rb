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
    OpenStruct.new(
      id: rand(1000),
      login_name: name,
      name: name,
      primary_role: role,
      avatar_url: 'https://via.placeholder.com/40',
      icon_title: name,
      online?: online,
      updated_at: online ? 5.minutes.ago : 2.hours.ago
    )
  end
end