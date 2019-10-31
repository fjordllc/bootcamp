# frozen_string_literal: true

namespace :fix_learning_status do
  desc "Learningのstatusに提出済みを追加するのに伴い、既存のstatusを数字順に修正"
  task :fix_learning_status do
    Learning.all.each do |learning|
      case learning.read_attribute_before_type_cast(:status)
      when 0 then
        learning.update!(status: "started")
      when 1 then
        learning.update!(status: "complete")
      when 2 then
        learning.update!(status: "not_complete")
      end
    end
  end
end
