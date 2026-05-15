# frozen_string_literal: true

module MockEnvHelper
  def mock_env(hash_for_mock, &block)
    env_hash = ENV.to_hash.merge(hash_for_mock)
    ENV.stub(:[], ->(key) { env_hash[key] }, &block)
  end
end
