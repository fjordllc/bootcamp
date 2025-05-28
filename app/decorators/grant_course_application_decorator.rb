# frozen_string_literal: true

module GrantCourseApplicationDecorator
  def full_name
    "#{last_name} #{first_name}"
  end

  def zip
    "#{zip1}-#{zip2}"
  end

  def address
    prefecture_address = prefecture.try(:name) || ''
    [prefecture_address, address1, address2].compact.join(' ')
  end

  def tel
    "#{tel1}-#{tel2}-#{tel3}"
  end

  def sender_name_and_email
    "#{full_name} (#{email})"
  end
end
