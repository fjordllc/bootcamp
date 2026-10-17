# frozen_string_literal: true

class WipRedirectUrl
  class << self
    def resolve(controller, resource)
      new(controller, resource).resolve
    end
  end

  def initialize(controller, resource)
    @controller = controller
    @resource = resource
  end

  def resolve
    @resource.wip? ? @controller.polymorphic_url(@resource, action: :edit) : @controller.polymorphic_url(@resource)
  end
end
