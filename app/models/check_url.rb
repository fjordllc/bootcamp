# frozen_string_literal: true

require "uri"
require "net/http"

class CheckUrl
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

  def access_url(url_array)
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


  def check_url
    # Docs
    page_id = Page.all.map(&:id)
    page_array = page_id.map do |id|
      { id: id, body: Page.find(id).body }
    end

    page_url = get_url(page_array).compact!
    modified_page_url = modify_url(page_url)
    page_error_url = access_url(modified_page_url).flatten.compact

    # Practice
    practice_id = Practice.all.map(&:id)
    practice_array = practice_id.map do |id|
      { id: id, body: Practice.find(id).description + Practice.find(id).goal }
    end

    practice_url = get_url(practice_array).compact!
    modified_practice_url = modify_url(practice_url)
    practice_error_url = access_url(modified_practice_url).flatten.compact

    # メール送信
    if page_error_url.size != 0 || practice_error_url.size != 0
      CheckUrlMailer.notify_error_url(page_error_url, practice_error_url).deliver_now
    end
  end
end
