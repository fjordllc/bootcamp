# frozen_string_literal: true

require 'test_helper'
require 'open3'

class ImportmapApplicationTest < ActiveSupport::TestCase
  test 'loads the DisposableStack polyfill only when Cocooned needs it' do
    application = Rails.root.join('app/javascript/importmap_application.js').read
    polyfill = Rails.application.importmap.packages['core-js/actual/disposable-stack']

    assert_equal 'disposable-stack-polyfill.js', polyfill.path
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

  test 'the polyfill implements DisposableStack' do
    polyfill = Rails.root.join('vendor/javascript/disposable-stack-polyfill.js')
    script = <<~'JAVASCRIPT'
      Object.defineProperty(globalThis, 'DisposableStack', { value: undefined, configurable: true })
      require(process.argv[1])
      const calls = []
      const stack = new DisposableStack()
      stack.use({ [Symbol.dispose]: () => calls.push('use') })
      stack.defer(() => calls.push('defer'))
      stack.dispose()
      if (calls.join(',') !== 'defer,use') process.exit(1)
    JAVASCRIPT

    _, error, status = Open3.capture3('node', '-e', script, polyfill.to_s)

    assert status.success?, error
    assert_includes polyfill.read, "defineWellKnownSymbol('dispose')"
  end
end
