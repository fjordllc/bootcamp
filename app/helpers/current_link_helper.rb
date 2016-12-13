module CurrentLinkHelper
  def current_link(path)
    if !path.include?('admin') && request.fullpath.include?('admin')
      false
    elsif request.fullpath.include?(path)
      'is-active'
    end
  end
end
