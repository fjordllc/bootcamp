# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  included do
  end

  def description
    case self
    when Report
      self[:description]
    when Page
      self[:body]
    end
  end
end
