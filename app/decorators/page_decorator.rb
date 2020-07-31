# frozen_string_literal: true

module PageDecorator
  def tag_list_links(delimiter)
    raw tag_list.map { |t| link_to t, pages_tag_path(t) }.join(delimiter)
  end
end
