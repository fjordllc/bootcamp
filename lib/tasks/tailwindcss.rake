# frozen_string_literal: true

# Clear the default tailwindcss:build task before redefining
Rake::Task['tailwindcss:build'].clear if Rake::Task.task_defined?('tailwindcss:build')
Rake::Task['tailwindcss:watch'].clear if Rake::Task.task_defined?('tailwindcss:watch')

TAILWIND_STYLESHEETS = %w[application lp not-logged-in paper].freeze

def tailwind_build_command(input, output, watch: false)
  command = [
    Tailwindcss::Ruby.executable,
    '-i', input.to_s,
    '-o', output.to_s,
    '--cwd', Rails.root.to_s
  ]
  command << '--minify' unless watch
  command << '-w' if watch
  command
end

# rubocop:disable Metrics/BlockLength
namespace :tailwindcss do
  desc 'Build all Tailwind CSS files'
  task build: :environment do
    TAILWIND_STYLESHEETS.each do |stylesheet|
      input = Rails.root.join("app/assets/stylesheets/#{stylesheet}.css")
      output = Rails.root.join("app/assets/builds/#{stylesheet}.css")

      next unless File.exist?(input)

      puts "Building #{stylesheet}.css..."
      system(*tailwind_build_command(input, output), exception: true)
    end
  end

  desc 'Watch and build Tailwind CSS files on changes'
  task watch: :environment do
    pids = []

    TAILWIND_STYLESHEETS.each do |stylesheet|
      input = Rails.root.join("app/assets/stylesheets/#{stylesheet}.css")
      output = Rails.root.join("app/assets/builds/#{stylesheet}.css")

      next unless File.exist?(input)

      puts "Watching #{stylesheet}.css..."
      pids << spawn(*tailwind_build_command(input, output, watch: true))
    end

    trap('INT') do
      pids.each do |pid|
        Process.kill('INT', pid)
      rescue StandardError
        nil
      end
      exit
    end

    Process.waitall
  end
end
# rubocop:enable Metrics/BlockLength
