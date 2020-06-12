# frozen_string_literal: true

require "uri"
require "net/http"

class CheckUrl
  def notify_error_url
    error_url_on_page = check_url(get_page_contents)
    error_url_on_practice = check_url(get_practice_contents)
    if error_url_on_page.size != 0 || practice_error_url.size != 0
      CheckUrlMailer.notify_error_url(error_url_on_page, error_url_on_practice).deliver_now
    end
  end

  private
    def get_url(contents_array)
      contents_array.map do |hash|
        unless URI.extract(hash[:contents]) == []
          { id: hash[:id], url: URI.extract(hash[:contents]) }
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
      url_array.map do |hash|
        hash[:url].map do |url|
          begin
            response = Net::HTTP.get_response(URI.parse(url))
          rescue SocketError
            next { id: hash[:id], url: url }
          end
          { id: hash[:id], url: url } unless response.code == "200" || response.code == "301"
        end
      end
    end

    def get_page_contents
      page_id = Page.all.map(&:id)
      page_id.map do |id|
        { id: id, contents: Page.find(id).body }
      end
    end

    def get_practice_contents
      practice_id = Practice.all.map(&:id)
      practice_id.map do |id|
        { id: id, contents: Practice.find(id).description + Practice.find(id).goal }
      end
    end

    def check_url(contents_array)
      url_array = get_url(contents_array).compact
      modified_url_array = modify_url(url_array)
      access_url(modified_url_array).flatten.compact
    end
end
