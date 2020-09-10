# frozen_string_literal: true

Rake::Task["db:fixtures:load"].execute
Rake::Task["bootcamp:statistics:save_learning_minute_statistics"].execute
