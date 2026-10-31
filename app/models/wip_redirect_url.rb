# frozen_string_literal: true

class WipRedirectUrl
  class << self
    def resolve(controller, resource)
      resource.wip? ? controller.polymorphic_url(resource, action: :edit) : controller.polymorphic_url(resource)
    end
  end
end
