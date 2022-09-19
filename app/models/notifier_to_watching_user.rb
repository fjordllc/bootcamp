# frozen_string_literal: true

class NotifierToWatchingUser
  def call(answer)
    question = Question.find(answer.question_id)
    mention_user_ids = answer.new_mention_users.ids
  
    return unless question.try(:watched?)
  
    watcher_ids = Watch.where(watchable_id: question.id).pluck(:user_id)
    watcher_ids.each do |watcher_id|
      if watcher_id != answer.sender.id && !mention_user_ids.include?(watcher_id)
        watcher = User.find_by(id: watcher_id)
        NotificationFacade.watching_notification(question, watcher, answer)
      end
    end
  end
end
