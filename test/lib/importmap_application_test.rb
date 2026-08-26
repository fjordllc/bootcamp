# frozen_string_literal: true

require 'test_helper'
class ImportmapApplicationTest < ActiveSupport::TestCase
  test 'loads the DisposableStack polyfill only when Cocooned needs it' do
    application = Rails.root.join('app/javascript/importmap_application.js').read
    polyfill = Rails.application.importmap.packages['core-js/actual/disposable-stack']

    assert_equal 'https://esm.sh/core-js@3.50.0/es2022/actual/disposable-stack.bundle.mjs', polyfill.path
    assert_not polyfill.preload
    assert_includes application, "document.querySelector('.cocooned-container')"
    assert_match(
      %r{if \(!globalThis\.DisposableStack \|\| !Symbol\.dispose\).*await import\('core-js/actual/disposable-stack'\)}m,
      application
    )
    polyfill_index = application.index("await import('core-js/actual/disposable-stack')")
    cocooned_index = application.index("await import('@notus.sh/cocooned')")
    assert_not_nil polyfill_index
    assert_not_nil cocooned_index
    assert_operator polyfill_index, :<, cocooned_index
    assert_includes application, "console.error('Failed to initialize Cocooned', error)"
  end
end
