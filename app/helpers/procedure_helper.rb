# frozen_string_literal: true

module ProcedureHelper
  def procedure(order, current)
    return unless order == current

    "is-active"
  end
end
