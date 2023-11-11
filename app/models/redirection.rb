# frozen_string_literal: true

class Redirection
  class << self
    def determin_url(controller, resource)
      new(controller, resource).determin_url
    end
  end

  def initialize(controller, resource)
    @controller = controller
    @resource = resource
  end

  def determin_url
    @resource.wip? ? @controller.polymorphic_url(@resource, action: :edit) : @controller.polymorphic_url(@resource)
  end
end
