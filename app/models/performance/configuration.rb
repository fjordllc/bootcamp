# frozen_string_literal: true

module Performance
  class Configuration
    attr_reader :project, :service, :region, :started_at

    def initialize(env = ENV)
      @collection = env['PERFORMANCE_COLLECTION_ENABLED'] == 'true'
      @dashboard = env['PERFORMANCE_DASHBOARD_ENABLED'] == 'true'
      @project = env['PERFORMANCE_PROJECT_ID'].to_s
      @service = env['PERFORMANCE_CLOUD_RUN_SERVICE'].to_s
      @region = env['PERFORMANCE_CLOUD_RUN_REGION'].to_s
      @started_at = Time.iso8601(env.fetch('PERFORMANCE_COLLECTION_STARTED_AT', ''))
    rescue ArgumentError
      @started_at = nil
    end

    def collection?
      @collection
    end

    def configured?
      @dashboard && started_at && valid_identity?
    end

    def valid_identity?
      project.match?(/\A[a-z][a-z0-9-]{4,28}[a-z0-9]\z/) &&
        service.match?(/\A[a-z][a-z0-9-]{0,62}\z/) && region.match?(/\A[a-z]+-[a-z]+[0-9]+\z/)
    end

    def identity
      [project, service, region].join(':')
    end
  end
end
