module PracticesHelper
  def rendering(text)
    Redcarpet::Markdown.new(
      Redcarpet::Render::HTML,
      no_intra_emphasis:   true,
      fenced_code_blocks:  true,
      autolink:            true,
      tables:              true,
      superscript:         true,
      space_after_headers: true
    ).render(text)
  end
end
