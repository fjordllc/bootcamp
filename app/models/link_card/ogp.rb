# frozen_string_literal: true

module LinkCard
  class Ogp
    def initialize(html)
      @html = html
    end

    def find_by(name)
      target = ogp_nodes.find { |node| node['property'] == "og:#{name}" }
      return '' if target.nil?

      target['content']
    end

    private

    def ogp_nodes
      @ogp_nodes ||= extract_ogp_nodes
    end

    def extract_ogp_nodes
      doc = Nokogiri::HTML(@html)
      doc.css('meta[property^="og:"]')
    end
  end
end
