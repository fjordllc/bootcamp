# frozen_string_literal: true

class UsersCurrentUserIconListComponentPreview < ViewComponent::Preview
  include PreviewHelper

  def default
    users = [
      build_mock_user(login_name: 'yamada', name: 'yamada', icon_title: 'yamada'),
      build_mock_user(id: 2, login_name: 'tanaka', name: 'tanaka', primary_role: 'mentor', icon_title: 'tanaka'),
      build_mock_user(id: 3, login_name: 'suzuki', name: 'suzuki', icon_title: 'suzuki')
    ]

    render(Users::CurrentUserIconListComponent.new(users: users))
  end

  def with_many_users
    users = (1..10).map do |i|
      build_mock_user(
        id: i, login_name: "user#{i}", name: "user#{i}",
        primary_role: i.even? ? 'student' : 'mentor', icon_title: "user#{i}"
      )
    end

    render(Users::CurrentUserIconListComponent.new(users: users))
  end
end
