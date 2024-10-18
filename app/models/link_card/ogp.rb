# frozen_string_literal: true

module LinkCard
  class Ogp
    def initialize(html)
      @html = html
    end

    def ogp_nodes
      @ogp_nodes ||= extract_ogp_nodes
    end

    def site_name
      find_content('site_name')
    end

    def url
      find_content('url')
    end

    def title
      find_content('title')
    end

    def description
      find_content('description')
    end

    def image
      find_content('image')
    end

    private

    def extract_ogp_nodes
      doc = Nokogiri::HTML(@html)
      doc.css('meta[property^="og:"]')
    end

    def find_content(name)
      target = ogp_nodes.find { |node| node['property'] == "og:#{name}" }
      target['content']
    end
  end
end
