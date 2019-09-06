# frozen_string_literal: true

module TagHelper
  def current_link(name)
    if qualified_page_name&.match?(name)
      "is-active"
    end
  end

  def qrcode_tag(url)
    borrowing_url = url.sub(/\/admin/, "").sub(/\/qrcode/, "")
    qrcode = RQRCode::QRCode.new(borrowing_url)
    qrcode.as_svg(module_size: 3).html_safe
  end

  private
    def qualified_page_name
      "#{controller_path.tr("/", "-")}-#{controller.action_name}"
    end
end
