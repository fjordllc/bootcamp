module PracticeDecorator
  def for
    t('for', target: t(self.target))
  end

  def status_button(user, target)
    { tag: 'button', class: 'btn', label: t(target) }
  end
end
