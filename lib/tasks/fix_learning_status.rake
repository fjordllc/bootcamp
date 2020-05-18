# frozen_string_literal: true

namespace :fix_learning_status do
  desc "Learningのstatusに提出済みを追加するのに伴い、既存のstatusを数字順に修正"
  task :fix_learning_status do
    Learning.all.each do |learning|
      case learning.read_attribute_before_type_cast(:status)
      when 0 then
        learning.status = "started"
        learning.save(validate: false)
      when 1 then
        learning.status = "complete"
        learning.save(validate: false)
      when 2 then
        learning.status = "unstarted"
        learning.save(validate: false)
      end
    end
  end
end
