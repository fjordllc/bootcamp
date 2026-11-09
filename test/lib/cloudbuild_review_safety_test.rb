# frozen_string_literal: true

require 'minitest/autorun'
require 'yaml'
require 'active_support/core_ext/enumerable'

class CloudbuildReviewSafetyTest < Minitest::Test
  CONFIG = YAML.safe_load_file(File.expand_path('../../.cloudbuild/cloudbuild-review.yaml', __dir__))

  def test_database_reset_waits_for_environment_generation_and_proxy_readiness
    steps = CONFIG.fetch('steps').index_by { |step| step.fetch('id') }
    prerequisites = ancestors(steps, 'CreateDB')

    assert_includes prerequisites, 'WriteSubstitutionEnv', 'DB reset must not start when environment generation fails'
    assert_includes prerequisites, 'WaitForProxy'
    # プロキシ起動と環境生成の並列性は維持する。
    %w[SqlProxy WaitForProxy WriteSubstitutionEnv].each do |id|
      assert_equal ['Push'], steps.fetch(id).fetch('waitFor')
    end
  end

  private

  def ancestors(steps, id)
    steps.fetch(id).fetch('waitFor', []).flat_map { |dependency| [dependency, *ancestors(steps, dependency)] }.uniq
  end
end
