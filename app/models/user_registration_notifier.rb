# frozen_string_literal: true

class UserRegistrationNotifier
  def call(user:, user_url:)
    decorated_user = ActiveDecorator::Decorator.instance.decorate(user)

    notify_to_mentors(user, decorated_user)
    notify_to_chat(user, decorated_user, user_url:)
  end

  private

  def notify_to_mentors(user, decorated_user)
    User.mentor.each do |mentor|
      ActivityDelivery.with(
        sender: user,
        receiver: mentor,
        sender_roles: decorated_user.roles_to_s
      ).notify(:signed_up)
    end
  end

  def notify_to_chat(user, decorated_user, user_url:)
    ChatNotifier.message "#{user.login_name}さん#{decorated_user.roles_to_s.empty? ? '' : "（#{decorated_user.roles_to_s}）"}が新たなメンバーとしてJOINしました🎉\r<#{user_url}>"
  end
end
