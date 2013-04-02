module ApplicationHelper
  def title(page_title)
    content_for(:title) {page_title}
    page_title
  end

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

  def practice_attr(practice)
    target = params['target'] || 'all'
    options =
      if target == 'all' or target.to_sym == practice.target
        {}
      else
        { style: 'display:none' }
      end
    options.merge(id: "practice_#{practice.id}", class: 'practice')
  end
end
