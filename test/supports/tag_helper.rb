# frozen_string_literal: true

module TagHelper
  def assert_alert_when_enter_tag_with_space
    [
      '半角スペースは 使えない',
      '全角スペースも　使えない'
    ].each { |tag| assert_alert_when_enter_tag(tag) }
  end

  def assert_alert_when_enter_one_dot_only_tag
    ['.'].each { |tag| assert_alert_when_enter_tag(tag) }
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
