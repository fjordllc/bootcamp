# frozen_string_literal: true

module AvatarHelper
  def reset_avatar(user)
    filename = "#{user.login_name}.jpg"
    path = Rails.root.join('test/fixtures/files/users/avatars', filename)
    user.avatar.attach(
      io: File.open(path, 'rb'),
      filename:,
      content_type: 'image/jpeg'
    )
  end
end
