# frozen_string_literal: true

module ApplicationHelper
  def my_practice?(practice)
    return false if current_user.blank?

    [:everyone, current_user.job].include?(practice.target)
  end

  def md2html(text)
    unless text.nil?
      options = {
        filter_html: true,
        autolink: true,
        space_after_headers: true,
        no_intra_emphasis: true,
        fenced_code_blocks: true,
        tables: true,
        hard_wrap: true,
        xhtml: true,
        lax_html_blocks: true,
        strikethrough: true
      }
      renderer = Redcarpet::Render::HTML.new(options)
      markdown = Redcarpet::Markdown.new(renderer)
    end

    markdown.render(text).html_safe
  end

  def md_summary(comment, word_count)
    summary = strip_tags(md2html(comment)).gsub(/[\r\n]/, '')
    simple_format(truncate(summary, length: word_count))
  end

  def searchable_summary(comment, word_count)
    summary = strip_tags(md2html(comment)).gsub(/[\r\n]/, '')
    truncate(summary, length: word_count)
  end
end
