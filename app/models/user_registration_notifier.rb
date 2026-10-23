# frozen_string_literal: true

class UserRegistrationNotifier
  def call(user:, user_url:)
    notify_to_mentors(user)
    notify_to_chat(user, user_url: user_url)
  end

  private

  def notify_to_mentors(user)
    User.mentor.each do |mentor|
      ActivityDelivery.with(
        sender: user,
        receiver: mentor,
        sender_roles: user.roles_to_s
      ).notify(:signed_up)
    end
  end

  def notify_to_chat(user, user_url)
    ChatNotifier.message "#{user.login_name}さん#{user.roles_to_s.empty? ? '' : "（#{user.roles_to_s}）"}が新たなメンバーとしてJOINしました🎉\r<#{user_url}>"
  end
end
