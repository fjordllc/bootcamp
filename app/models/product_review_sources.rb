# frozen_string_literal: true

require 'vips'

# Fetch only references in the submission, before any private mentor context reaches the model.
class ProductReviewSources
  MAX_SOURCES = 10
  MAX_BODY_BYTES = 10.megabytes
  MAX_IMAGE_BYTES = 7.megabytes
  MAX_ATTACHMENTS_BYTES = 20.megabytes
  REQUEST_TIMEOUT = 15
  IMAGE_TYPES = %w[image/jpeg image/png image/gif image/webp].freeze
  UNAVAILABLE = '未確認: 取得できませんでした（認証、通信、対応形式、10MBの取得上限など）。'

  attr_reader :evidence, :attachments

  def initialize(body)
    @body = body
    @evidence = []
    @attachments = []
    @attachment_bytes = 0
  end

  def collect
    html = Kramdown::Document.new(@body.to_s, input: 'GFM', hard_wrap: true).to_html
    urls = referenced_urls(html).map { |value| normalize_url(value) }.uniq(&:first)
    urls.each_with_index do |(url, reason), index|
      reason ||= '未確認: 取得対象の上限10件を超えています。' if index >= MAX_SOURCES
      @evidence << (reason ? unavailable(url, reason) : fetch(url))
    end
    self
  end

  private

  def referenced_urls(html)
    document = Nokogiri::HTML::DocumentFragment.parse(html)
    document.css('code, pre, script, style').remove
    document.xpath('.//a[@href] | .//img[@src] | .//text()[not(ancestor::a)]').flat_map do |node|
      if node.text?
        linked = ActionController::Base.helpers.auto_link(ERB::Util.html_escape(node.text), link: :urls)
        Nokogiri::HTML::DocumentFragment.parse(linked).css('a[href]').map { |link| link['href'] }
      else
        [node[node.name == 'a' ? 'href' : 'src']]
      end
    end
  end

  def normalize_url(value)
    uri = URI.parse(value)
    uri = URI.join(Rails.application.routes.url_helpers.root_url, value) if uri.relative?
    uri.fragment = nil
    return [uri.to_s, '未確認: httpまたはhttps以外のURLです。'] unless uri.is_a?(URI::HTTP) && uri.host.present?

    if uri.userinfo
      uri.password = nil
      uri.user = nil
      return [uri.to_s, '未確認: 認証情報を含むURLは取得しません。']
    end
    [uri.to_s, nil]
  rescue URI::InvalidURIError, ArgumentError
    ['(不正なURL)', '未確認: URLの形式またはアプリのURL設定を確認できません。']
  end

  def fetch(url)
    reader = if ExternalContent::GithubReviewReader.support?(URI.parse(url))
               ExternalContent::GithubReviewReader
             else
               ExternalContent::WebPageReader
             end
    result = reader.fetch(url, max_body_bytes: MAX_BODY_BYTES, request_timeout: REQUEST_TIMEOUT, log_errors: false)
    return image_evidence(url, *result) if result.is_a?(Array)
    return unavailable(url, UNAVAILABLE) unless result.to_s.start_with?("# Web Page\n", "# GitHub Review Source\n")

    { url:, status: 'fetched', content: result }
  rescue StandardError
    # Neither URLs (which may contain signed queries) nor response bodies belong in logs.
    unavailable(url, UNAVAILABLE)
  end

  def image_evidence(url, content, attachment)
    return unavailable(url, '未確認: 対応していない画像形式です。JPEG・PNG・GIF・WebPのみ確認できます。') unless IMAGE_TYPES.include?(attachment.mime_type)
    return unavailable(url, '未確認: 画像添付の上限7MBを超えています。') if attachment.content.bytesize > MAX_IMAGE_BYTES
    return unavailable(url, '未確認: 画像添付の合計上限20MBを超えています。') if @attachment_bytes + attachment.content.bytesize > MAX_ATTACHMENTS_BYTES

    image = Vips::Image.new_from_buffer(attachment.content, '', access: :sequential)
    return unavailable(url, '未確認: 画像の幅または高さが8000pxを超えています。') if image.width > 8000 || image.height > 8000

    @attachments << attachment
    @attachment_bytes += attachment.content.bytesize
    { url:, status: 'image_attached', content:, attachment_number: attachments.size }
  end

  def unavailable(url, reason)
    { url:, status: 'unavailable', reason: }
  end
end
