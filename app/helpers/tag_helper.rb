# frozen_string_literal: true

module TagHelper
  def current_link(name)
    if qualified_page_name&.match?(name)
      "is-active"
    end
  end

  def qrcode_tag(url, size: 1.8)
    RQRCode::QRCode.new(url)
      .as_svg(module_size: size).html_safe
  end

  private

    def qualified_page_name
      "#{controller_path.tr("/", "-")}-#{controller.action_name}"
    end
end
