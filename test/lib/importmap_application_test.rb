# frozen_string_literal: true

require 'test_helper'
require 'open3'

class ImportmapApplicationTest < ActiveSupport::TestCase
  test 'loads the DisposableStack polyfill only when Cocooned needs it' do
    application = Rails.root.join('app/javascript/importmap_application.js').read
    importmap = Rails.root.join('config/importmap.rb').read

    assert_includes importmap, 'pin "core-js/actual/disposable-stack", to: "disposable-stack-polyfill.js", preload: false'
    assert_includes application, "document.querySelector('.cocooned-container')"
    assert_match(%r{if \(!globalThis\.DisposableStack\).*await import\('core-js/actual/disposable-stack'\)}m, application)
    assert_operator application.index("await import('core-js/actual/disposable-stack')"), :<,
                    application.index("await import('@notus.sh/cocooned')")
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
