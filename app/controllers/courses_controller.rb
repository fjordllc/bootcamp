class CoursesController < ApplicationController
  before_action :require_login
  respond_to :yaml

  def index
    output = ''
    Practice.order('position').each do |c|
      output += <<-EOS
lesson_#{c.id}:
  id: #{c.id}
  title: "#{c.title}"
  body: "#{c.description.encode("UTF-16BE", "UTF-8", invalid: :replace, undef: :replace, replace: '.').encode("UTF-8")}"
  goal: "#{c.goal.encode("UTF-16BE", "UTF-8", invalid: :replace, undef: :replace, replace: '.').encode("UTF-8")}"
  course_id: #{c.category_id}
  position: #{c.position}

      EOS
    end

    render :inline => output, :content_type => 'text/yaml'
  end
end
