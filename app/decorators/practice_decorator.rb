# coding: utf-8
module PracticeDecorator

  def status(user_id)
    learning = Learning.find_by(user_id: user_id, practice_id: self.id)
    learning.present? ? learning.status : :unstarted
  end

  def learning_status(user_id)
    status = self.status(user_id).to_s
    content_tag(:p, id: "practice-#{self.id}", class: "status #{status}") do
      content_tag(:span, "#{status}", class: btn_color(status))
    end
  end

  private
    def btn_color(status)
      case status
      when 'unstarted'
        'btn'
      when 'active'
        'btn btn-info'
      when 'complete'
        'btn btn-success'
      end
    end
end
