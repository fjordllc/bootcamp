# frozen_string_literal: true

task :check_url do
  CheckUrl.new.notify_error_url
end
