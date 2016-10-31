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

  def markdown(text)
    render = Redcarpet::Render::HTML.new(hard_wrap: true)
    markdown_options = { autolink: true, no_intra_emphasis: true, tables: true }
    markdown = Redcarpet::Markdown.new(render, markdown_options)
    markdown.render(text).html_safe
  end
end
