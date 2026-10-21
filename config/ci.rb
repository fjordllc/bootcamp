# Run using bin/ci. Rails 8.1 provides per-step and total timing reports.

CI.run do
  step 'Dependencies: Ruby (install with bundle install if missing)', 'bundle', 'check'
  step 'Style: Ruby', 'bundle', 'exec', 'rubocop', '--ignore-parent-exclusion', '--format', 'progress' if success?
  step 'Style: Slim', 'bundle', 'exec', 'slim-lint', 'app/views', '-c', 'config/slim_lint.yml' if success?
  step 'Routes: Traceroute', 'env', 'RAILS_ENV=development', 'FAIL_ON_ERROR=1', 'bundle', 'exec', 'rake', 'traceroute' if success?
  step 'Dependencies: JavaScript', 'npm', 'ci' if success?
  step 'Style: JavaScript, CSS and OpenAPI', 'npm', 'run', 'lint' if success?

  step 'Database: Prepare test database', 'bin/rails', 'db:prepare' if success?
  step 'Assets: Precompile', 'bin/rails', 'assets:clean', 'assets:precompile' if success?
  step 'Tests: Rails including system tests', 'bin/rails', 'test:all' if success?

  if success? && ARGV.include?('--signoff')
    if signoff_head == SIGNOFF_HEAD
      step 'Signoff: All checks passed', 'gh', 'signoff'
    else
      results << false
      failure 'Signoff skipped: checkout changed during CI. Commit, push and run again.'
    end
  end
end
