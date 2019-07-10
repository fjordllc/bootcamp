# frozen_string_literal: true

module UserDecorator
  def twitter_url
    "https://twitter.com/#{twitter_account}"
  end

  def role
    roles = [
      { role: :admin, value: admin },
      { role: :mentor, value: mentor },
      { role: :adviser, value: adviser },
      { role: :trainee, value: trainee },
      { role: :graduate, value: graduated_on },
      { role: :student, value: true }
    ]
    roles.detect { |v| v[:value] }[:role]
  end

  def avatar_image
    if avatar.attached?
      avatar.service_url
    else
      image_path("users/avatars/default.png")
    end
  end

  def url
    user_url(self)
  end
end
