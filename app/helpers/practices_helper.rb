module PracticesHelper
  def rendering(text)
    Redcarpet::Markdown.new(
      Redcarpet::Render::HTML,
      no_intra_emphasis:   true,
      fenced_code_blocks:  true,
      autolink:            true,
      tables:              true,
      superscript:         true,
    ).render(text).html_safe
  end

  def qiita_markdown(markdown)
    processor = Qiita::Markdown::Processor.new
    processor.call(markdown)[:output].to_s.html_safe
  end
end
