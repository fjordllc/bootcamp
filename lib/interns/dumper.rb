module Interns
  class Dumper
    class << self
      def dump_categories
        Category.order('position').each do |c|
          puts <<-EOS
courses_#{c.id}:
  id: #{c.id}
  title: "#{c.name}"
  slug: "#{c.slug}"
  body: "#{c.description}"
  position: #{c.position}

          EOS
        end
      end

      def dump_practices
        Practice.order('position').each do |c|
          puts <<-EOS
lesson_#{c.id}:
  id: #{c.id}
  title: "#{c.title}"
  body: "#{c.description.encode("UTF-16BE", "UTF-8", invalid: :replace, undef: :replace, replace: '.').encode("UTF-8")}"
  goal: "#{c.goal.encode("UTF-16BE", "UTF-8", invalid: :replace, undef: :replace, replace: '.').encode("UTF-8")}"
  course_id: #{c.category_id}
  position: #{c.position}

          EOS
        end
      end

      def dump_users
        User.all.each do |c|
          puts <<-EOS
user_#{c.id}:
  id: #{c.id}
          EOS
        end
      end

    end
  end
end
