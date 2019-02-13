# frozen_string_literal: true

module CommentsHelper
  def user_comments_page?
    controller_path == "users/comments" && action_name == "index"
  end

  def md2html(text)
    html = CommonMarker.render_html(text)
    raw(html)
  end

  def comment_summury(comment, word_count)
    summury = strip_tags(md2html(comment)).gsub(/[\r\n]/, "")
    simple_format(truncate(summury, length: word_count))
  end
end
