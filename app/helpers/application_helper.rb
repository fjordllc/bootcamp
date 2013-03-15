module ApplicationHelper
  def li_for(record, prefix = nil, options = nil, &block)
    content_tag_for(:li, record, prefix, options, &block)
  end

  def tr_for(record, prefix = nil, options = nil, &block)
    content_tag_for(:tr, record, prefix, options, &block)
  end

  def view_slug
    controller.
      class.to_s.underscore.gsub(%r{/}, "-").
      gsub(/_controller/, "_") + action_name
  end
end
