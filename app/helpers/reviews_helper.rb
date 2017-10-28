module ReviewsHelper
  def shallow_args(parent, child)
    child.try(:new_record?) ? [parent, child] : child
  end
end
