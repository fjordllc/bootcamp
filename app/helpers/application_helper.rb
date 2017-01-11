module ApplicationHelper
  def title(page_title)
    content_for(:title) {page_title}
    page_title
  end

  def page_slug
    controller.class.to_s.underscore.
      gsub(%r{/}, "-").
      gsub(/_controller/, "_") + action_name
  end

  def my_practice?(practice)
    return false if current_user.blank?
    [:everyone, current_user.job].include?(practice.target)
  end
end
