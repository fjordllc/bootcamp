# frozen_string_literal: true

namespace :db do
  namespace :files do
    desc "Upload files."
    task load: :"db:fixtures:load" do
      Bootcamp::Setup.attachment
    end
  end
end

Rake::Task["db:fixtures:load"].enhance do
  Rake::Task["db:files:load"].execute
end
