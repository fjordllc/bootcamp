require Rails.root.join('lib', 'interns', 'render')

module MarkdownHelper
  def markdown(text)
    render = Interns::Render.new(hard_wrap: true)
    markdown_options = { autolink: true, no_intra_emphasis: true, tables: true }
    markdown = CheckboxMarkdown.new(render, markdown_options)
    markdown.render(text).html_safe
  end
end
