# frozen_string_literal: true

module Taskable
  def body
    self[:body] || self[:description]
  end

  def toggle_task(nth, checked)
    body.gsub!(/^\s*-\s*\[(x| )\]\s*/).with_index do |m, i|
      if i == nth
        checked ? '- [x] ' : '- [ ] '
      else
        m
      end
    end
  end

  def toggleable?(other_user)
    user == other_user
  end
end
