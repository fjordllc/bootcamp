# frozen_string_literal: true

module UserFlags
  extend ActiveSupport::Concern

  included do
    flag :retire_reasons, %i[
      done
      necessity
      other_school
      time
      motivation
      curriculum
      support
      environment
      cost
      job_change
      training_end
    ]

    flag :experiences, %i[
      html_css
      ruby
      rails
      javascript
      react
      languages_other_than_ruby_and_javascript
    ]
  end
end
