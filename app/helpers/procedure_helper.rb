module ProcedureHelper
  def procedure(order, current)
    if order == current
      'is-active'
    end
  end
end
