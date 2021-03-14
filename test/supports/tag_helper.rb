# frozen_string_literal: true

module TagHelper
  def assert_alert_when_enter_tag_with_space
    assert_alert_when_enter_tag('半角スペースは 使えない')
  end

  private

  def assert_alert_when_enter_tag(name)
    tag_input = find('.ti-new-tag-input')
    tag_input.set name
    page.accept_alert do
      tag_input.native.send_keys :return
    end
  end
end
