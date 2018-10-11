# frozen_string_literal: true

module ChecksHelper
  def checkable_url(check)
    case check.checkable
    when Report
      polymorphic_url(check.checkable)
    when Product
      polymorphic_url([check.checkable.practice, check.checkable])
    end
  end
end
