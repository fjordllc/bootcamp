# frozen_string_literal: true

module TagHelper
  def current_link(name)
    return unless qualified_page_name&.match?(name)

    'is-active'
  end

  def qrcode_tag(url, size: 1.8)
    RQRCode::QRCode.new(url)
                   .as_svg(module_size: size).html_safe # rubocop:disable Rails/OutputSafety
  end

  def qualified_page_name
    "#{qualified_controller_name}-#{action_name}"
  end
end
