# frozen_string_literal: true

require "uri"
require "net/http"

def get_url(contents_array)
  contents_array.map do |page|
    unless URI.extract(page[:body]) == []
      { id: page[:id], url: URI.extract(page[:body]) }
    end
  end
end

def modify_url(url_array)
  url_array.each do |hash|
    hash[:url].each do |url|
      if url[-1] == ")"
        { id: hash[:id], url: url.chop! }
      else
        { id: hash[:id], url: url }
      end
    end
  end
end

def check_url(url_array)
  url_array.map do |value|
    value[:url].map do |url|
      begin
        response = Net::HTTP.get_response(URI.parse(url))
      rescue SocketError
        next { id: value[:id], url: url }
      end
      { id: value[:id], url: url } unless response.code == "200" || response.code == "301"
    end
  end
end

namespace :check_url do
  desc "全てのDocsの本文を取得"
  task :get_page_contents do
    page_id = Page.all.map(&:id)
    PAGE_ARRAY = page_id.map do |id|
      { id: id, body: Page.find(id).body }
    end
  end

  desc "全てのプラクティスの本文と完了条件を取得"
  task :get_practice_contents do
    practice_id = Practice.all.map(&:id)
    PRACTICE_ARRAY = practice_id.map do |id|
      { id: id, body: Practice.find(id).description + Practice.find(id).goal }
    end
  end

  desc "Docsの本文の中からURLを取得"
  task get_page_url: :get_page_contents do
    PAGE_URL = get_url(PAGE_ARRAY).compact!
  end

  desc "プラクティスの本文と完了条件の中からURLを取得"
  task get_practice_url: :get_practice_contents do
    PRACTICE_URL = get_url(PRACTICE_ARRAY).compact!
  end

  desc "取得したURLの最後に`)`がついている場合はそれを削除"
  task modify_url: [:get_page_url, :get_practice_url] do
    MODIFIED_PAGE_URL = modify_url(PAGE_URL)
    MODIFIED_PRACTICE_URL = modify_url(PRACTICE_URL)
  end

  desc "リンク切れのURLを取得"
  task check_url: :modify_url do
    PAGE_ERROR_URL = check_url(MODIFIED_PAGE_URL).flatten.compact
    PRACTICE_ERROR_URL = check_url(MODIFIED_PRACTICE_URL).flatten.compact
  end

  desc "リンク切れURLをメールで通知"
  task send_email: :check_url do
    if PAGE_ERROR_URL.size != 0 || PRACTICE_ERROR_URL.size != 0
      CheckUrlMailer.notify_error_url(PAGE_ERROR_URL, PRACTICE_ERROR_URL).deliver_now
    end
  end
end
