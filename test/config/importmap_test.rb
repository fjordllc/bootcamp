# frozen_string_literal: true

require 'test_helper'

class ImportmapTest < ActiveSupport::TestCase
  test 'application dependencies are served locally' do
    importmap = Rails.application.importmap.to_json(resolver: ActionController::Base.helpers)
    imports = JSON.parse(importmap).fetch('imports')
    dependencies = [
      '@notus.sh/cocooned',
      '@rails/request.js',
      '@rails/ujs',
      '@yaireo/tagify',
      'ace-builds',
      'autosize',
      'chart.js',
      'chartjs-plugin-annotation',
      'chartjs-plugin-datalabels',
      'choices.js',
      'escape-html',
      'escape-string-regexp',
      'heic2any',
      'markdown-it',
      'markdown-it-anchor',
      'markdown-it-container',
      'markdown-it-container-figure',
      'markdown-it-emoji',
      'markdown-it-link-attributes',
      'markdown-it-regexp',
      'markdown-it-task-lists',
      'prismjs',
      'sortablejs',
      'sweetalert2',
      'textarea-markdown',
      'tributejs'
    ]
    application_dependencies = imports.slice(*dependencies)

    assert_equal dependencies.size, application_dependencies.size
    assert(application_dependencies.values.all? { |path| path.start_with?('/assets/') })
  end
end
