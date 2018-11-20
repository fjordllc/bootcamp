# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  included do
  end

  def description
    case self
    when Page
      self[:body]
    else
      self[:description]
    end
  end
end
