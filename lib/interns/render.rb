module Interns
  class Render < Redcarpet::Render::HTML
    def postprocess(text)
      text.gsub(/\[\[(.+)\]\]/, '<a href="/pages/\1">\1</a>')
    end
  end
end
