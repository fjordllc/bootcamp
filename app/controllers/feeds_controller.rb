class FeedsController < ApplicationController
  respond_to :html, :atom

  def index
    urls = User.pluck(:feed_url).reject { |f| f.blank?}
    hydra = Typhoeus::Hydra.new
    requests = urls.map do |url|
      req = Typhoeus::Request.new(url, followlocation: true)
      hydra.queue(req)
      req
    end
    hydra.run

    @entries = []
    requests.each do |req|
      begin
        feed = Feedjira::Feed.parse(req.response.options[:response_body])
        if feed.class == Feedjira::Parser::Atom
          feed.entries.each do |entry|
            @entries << entry
          end
        elsif feed.class == Feedjira::Parser::RSS
          feed.entries.each do |entry|
            @entries << entry
          end
        else
          raise "Unknown feed format."
        end
      rescue
        next
      end
    end
    @entries.sort! { |a, b| b.published <=> a.published }
    @entries
  end
end
