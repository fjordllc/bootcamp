# frozen_string_literal: true

require 'application_system_test_case'

class MarkdownSecurityTest < ApplicationSystemTestCase
  test 'unsafe HTML cannot execute in preview or saved Markdown' do
    visit_with_auth new_page_path, 'komagata'
    fill_in 'page[title]', with: 'Markdown security'
    fill_in 'page[body]', with: <<~MARKDOWN
      <p>security sentinel</p>
      <img src="/missing-markdown-security-image" onerror="window.markdownSecurityMarker = true">
      <a href="javascript:window.markdownSecurityMarker=true">unsafe link</a>
      <a href="data:text/html,unsafe">unsafe data link</a>
      <p onmouseover="window.markdownSecurityMarker=true">unsafe event</p>
      <script>window.markdownSecurityMarker = true</script>
      <svg onload="window.markdownSecurityMarker=true"><circle /></svg>
      <math><mi>math content</mi></math>
      <iframe srcdoc="<script>parent.markdownSecurityMarker=true</script>"></iframe>
      <iframe src="/missing-markdown-security-frame"></iframe>
      <form><input name="markdownSecurityMarker"></form>
      <style>body { display: none; }</style>
    MARKDOWN

    assert_safe_markdown '.js-preview'
    click_button 'Docを公開'
    assert_safe_markdown '.a-long-text.is-md.js-markdown-view'
  end

  test 'custom Markdown and ordinary raw formatting survive preview and saving' do
    reset_avatar(users(:komagata))
    visit_with_auth new_page_path, 'komagata'
    fill_in 'page[title]', with: 'Markdown compatibility'
    fill_in 'page[body]', with: <<~MARKDOWN
      :::message success
      compatible message
      :::

      :::details compatible details
      details body
      :::

      :::speak @komagata
      speak body
      :::

      :::figure
      <img src="/favicon.ico" alt="compatible image">
      compatible caption
      :::

      @komagata :@komagata:

      - [x] completed task
      - [ ] pending task

      | heading |
      | ------- |
      | cell    |

      ```ruby
      puts 'compatible code'
      ```

      <blockquote>compatible quotation</blockquote>
      <p style="color: red;" data-compatible="yes">compatible color</p>
    MARKDOWN

    assert_compatible_markdown '.js-preview'
    click_button 'Docを公開'
    assert_compatible_markdown '.a-long-text.is-md.js-markdown-view'
  end

  test 'video embeds allow only exact HTTPS providers without loading external frames' do
    visit_with_auth new_page_path, 'komagata'
    markdown = <<~MARKDOWN
      [youtube:abc_123-XYZ]
      [vimeo:123456]
      <iframe src="https://youtube.com/embed/abc_123-XYZ"></iframe>
      <iframe src="https://www.youtube.com.evil.example/embed/abc"></iframe>
      <iframe src="https://www.youtube.com@evil.example/embed/abc"></iframe>
      <iframe src="https://evil@www.youtube.com/embed/abc"></iframe>
      <iframe src="http://www.youtube.com/embed/abc"></iframe>
      <iframe src="https://www.youtube.com:444/embed/abc"></iframe>
      <iframe src="https://www.youtube.com/watch?v=abc"></iframe>
      <iframe src="https://player.vimeo.com/video/not-numeric"></iframe>
      <iframe src="https://www.youtube.com/embed/abc" srcdoc="unsafe"></iframe>
    MARKDOWN
    # Parse the render result in a detached element: assertions do not contact video providers.
    result = page.evaluate_async_script(<<~JS, markdown)
      const markdown = arguments[0]
      const done = arguments[arguments.length - 1]
      import('markdown-initializer').then(({ default: Markdown }) => {
        const element = document.createElement('div')
        element.innerHTML = new Markdown().render(markdown)
        done(Array.from(element.querySelectorAll('iframe')).map(frame => ({
          src: frame.getAttribute('src'),
          allow: frame.getAttribute('allow'),
          hasSrcdoc: frame.hasAttribute('srcdoc')
        })))
      })
    JS

    assert_equal ['https://www.youtube.com/embed/abc_123-XYZ',
                  'https://player.vimeo.com/video/123456?badge=0&autopause=0&player_id=0&app_id=58479',
                  'https://youtube.com/embed/abc_123-XYZ'], result.pluck('src')
    assert_includes result.first['allow'], 'autoplay'
    assert(result.none? { |frame| frame['hasSrcdoc'] }, "Unexpected iframe attributes: #{result.inspect}")
  end

  test 'downstream tweet and link card HTML is sanitized before insertion' do
    visit_with_auth new_page_path, 'komagata'
    # Local metadata responses avoid third-party HTTP requests and widget loading.
    page.execute_script(<<~JS)
      const widget = document.createElement('script')
      widget.type = 'application/json'
      widget.src = 'https://platform.twitter.com/widgets.js'
      document.body.appendChild(widget)
      const originalFetch = window.fetch
      window.fetch = (url, options) => {
        if (!String(url).startsWith('/api/metadata?')) return originalFetch(url, options)
        const attack = '<img src="/missing-card-security-image" onerror="window.markdownSecurityMarker=true">'
        const data = String(url).includes('tweet=1') ? {
          html: '<blockquote class="twitter-tweet">safe tweet' + attack +
            '<script src="/untrusted-widget.js"></script>' +
            '<a href="javascript:window.markdownSecurityMarker=true">unsafe tweet link</a></blockquote>'
        } : {
          title: 'safe card' + attack,
          description: '<svg onload="window.markdownSecurityMarker=true"></svg>safe description',
          site_url: 'javascript:window.markdownSecurityMarker=true',
          images: '/favicon.ico',
          favicon: '/favicon.ico',
          site_name: 'safe site'
        }
        return Promise.resolve({ ok: true, json: () => Promise.resolve(data) })
      }
    JS
    fill_in 'page[body]', with: <<~MARKDOWN
      @[card](https://x.com/fixture/status/123456)

      @[card](https://example.com/fixture)
    MARKDOWN

    within '.js-preview' do
      assert_selector '.twitter-tweet', text: 'safe tweet'
      assert_selector '.a-link-card__title', text: 'safe card'
      assert_no_selector 'script, svg, [onerror], a[href^="javascript:"]', visible: :all
    end
    assert_nil page.evaluate_script('window.markdownSecurityMarker')
  end

  test 'failed card fallback cannot insert unsafe HTML from its URL' do
    visit_with_auth new_page_path, 'komagata'
    page.execute_script(<<~JS)
      const originalFetch = window.fetch
      window.fetch = (url, options) => String(url).startsWith('/api/metadata?') ?
        Promise.resolve({ ok: false, status: 400 }) : originalFetch(url, options)
      const target = document.createElement('div')
      target.className = 'before-replacement-link-card'
      target.dataset.url = 'javascript:window.markdownSecurityMarker=true"><img src="/missing-fallback-image" onerror="window.markdownSecurityMarker=true">'
      document.querySelector('.js-preview').appendChild(target)
    JS
    page.evaluate_async_script(<<~JS)
      const done = arguments[arguments.length - 1]
      import('replace-link-to-card').then(({ default: replace }) => {
        replace('.js-preview')
        done()
      })
    JS

    within '.js-preview' do
      assert_selector '.embed-error'
      assert_no_selector '[onerror], a[href^="javascript:"]', visible: :all
    end
    assert_nil page.evaluate_script('window.markdownSecurityMarker')
  end

  private

  def assert_safe_markdown(selector)
    within selector do
      assert_selector 'p', text: 'security sentinel'
      assert_no_selector 'script, style, svg, math, iframe, form, [onerror], [onmouseover], [srcdoc]', visible: :all
      assert_no_selector 'a[href^="javascript:"], a[href^="data:"]', visible: :all
      assert_text 'unsafe link'
    end
    assert_nil page.evaluate_script('window.markdownSecurityMarker')
  end

  def assert_compatible_markdown(selector)
    within selector do
      assert_selector '.message.success', text: 'compatible message'
      assert_selector 'details summary', text: 'compatible details'
      assert_selector '.speak a[href="/users/komagata"]'
      assert_selector 'figure figcaption', text: 'compatible caption'
      assert_selector 'a.a-user-emoji-link img[title="@komagata"]'
      assert_selector 'input.task-list-item-checkbox[checked]', visible: :all
      assert_selector 'input.task-list-item-checkbox:not([checked])', visible: :all
      assert_selector 'table td', text: 'cell'
      assert_selector 'pre code', text: "puts 'compatible code'"
      assert_selector 'blockquote', text: 'compatible quotation'
      assert_selector 'p[style*="color"][data-compatible="yes"]', text: 'compatible color'
    end
  end
end
