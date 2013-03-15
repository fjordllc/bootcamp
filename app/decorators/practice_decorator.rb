module PracticeDecorator
  def status(user_id)
    learning = Learning.find_by(user_id: user_id, practice_id: self.id)
    learning.present? ? learning.status : :unstarted
  end

  def learning_status(user_id)
    status = self.status(user_id).to_s
    content_tag(:div, id: "practice-#{self.id}", class: 'btn-group') do
      btn_group.each do |btn_name, btn_class|
        concat generate_button(status, btn_name, btn_class)
      end
    end
  end

  def for
    t('for', aim: t(self.aim))
  end

  private
    def btn_group
      { 'unstarted' => 'btn', 'active' => 'btn btn-info', 'complete' => 'btn btn-success' }
    end

    def generate_button(status, btn_name, btn_class)
      btn_class += " #{btn_name}"
      btn_class += ' disabled' if status != btn_name
      content_tag(:button, I18n.t(btn_name), class: btn_class)
    end
end
