# frozen_string_literal: true

class QuestionCallbacks
  def after_create(question)
    send_notification_to_mentors(question)
    notify_followers(question)
    Cache.delete_not_solved_question_count
  end

  def after_destroy(question)
    delete_notification(question)
    Cache.delete_not_solved_question_count
  end

  private

  def send_notification_to_mentors(question)
    User.mentor.each do |user|
      NotificationFacade.came_question(question, user) if question.sender != user
    end
  end

  def delete_notification(question)
    Notification.where(link: "/questions/#{question.id}").destroy_all
  end

  def send_notification(product:, receivers:, message:)
    receivers.each do |receiver|
      NotificationFacade.submitted(product, receiver, message)
    end
  end

  def notify_followers(question)
    followers = question.user.followers
    send_notification(
      product: question,
      receivers: followers,
      message: "#{question.user.login_name}さんから質問がありました。"
    )
    question.user.followers.each do |follower|
      create_following_watch(question, follower) if follower.watching?(question.user)
    end
  end

  def create_following_watch(question, follower)
    Watch.create!(user: follower, watchable: question)
  end

end
