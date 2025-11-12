# frozen_string_literal: true

module Doorkeeper
  class ApplicationsController < ::Doorkeeper::ApplicationsController
    private

    def redirect_to(options = {}, response_options = {})
      super(options, response_options.merge(allow_other_host: true))
    end
  end
end
