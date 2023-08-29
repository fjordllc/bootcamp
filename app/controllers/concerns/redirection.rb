# frozen_string_literal: true

module Redirection
  extend ActiveSupport::Concern

  private

  def redirect_url(resource)
    resource.wip? ? polymorphic_url(resource, action: :edit) : polymorphic_url(resource)
  end
end
