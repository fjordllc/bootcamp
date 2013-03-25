module PracticeDecorator
  def current_status(user_id)
    learning = Learning.find_by(user_id: user_id, practice_id: self.id)
    learning.present? ? learning.status.to_s : 'unstarted'
  end

  def learning_status(user_id)
    status = current_status(user_id).to_s
    content_tag(
      :button,
      I18n.t(status),
      id: "practice-#{self.id}",
      class: btn_class(status)
    )
  end

  def for
    t('for', target: t(self.target))
  end

  private
    def btn_class(status)
      "#{status} btn"
    end
end
