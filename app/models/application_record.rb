# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def anchor
    "#{self.class.to_s.tableize.singularize}_#{id}"
  end

  def path
    Rails.application.routes.url_helpers.polymorphic_path(self)
  end
end
