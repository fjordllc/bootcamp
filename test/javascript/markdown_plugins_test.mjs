import './support/importmap_resolver.mjs'
import assert from 'node:assert/strict'
import test from 'node:test'

const { default: MarkdownIt } = await import('markdown-it')
const { default: speak } = await import('markdown-it-container-speak')
const { default: figure } = await import('markdown-it-container-figure')
const { default: externalLink } = await import('markdown-it-external-link')

const origin = 'http://localhost:3000'
globalThis.location = { origin }

const render = (plugin, text) => new MarkdownIt({ html: true, breaks: true, linkify: true }).use(plugin).render(text)
const anchorTag = (html, text) => html.match(new RegExp(`<a [^>]*>${text}</a>`))[0]

test('speak block with @ links to the user and shows the user icon', () => {
  const html = render(speak, ':::speak @mentormentaro\n## 質問\nあああ\nいいい\n:::')
  assert.match(html, /<div class="speak">/)
  assert.match(html, /<a href="\/users\/mentormentaro" class="a-user-emoji-link">/)
  assert.match(html, /<img title="@mentormentaro" class="a-user-emoji" src="\/@mentormentaro.webp">/)
  assert.match(html, /<h2>質問<\/h2>/)
})

test('speak block with name and image URL shows the image without a link', () => {
  const html = render(speak, ':::speak(machida, https://avatars.githubusercontent.com/u/168265?v=4)\n## (名前, 画像URL)ver\n:::')
  assert.match(html, /<div class="speak">/)
  assert.doesNotMatch(html, /href="\/users\/machida"/)
  assert.match(html, /<img src="https:\/\/avatars.githubusercontent.com\/u\/168265\?v=4" alt="machida" title="@machida"/)
  assert.match(html, /<span class="speak__speaker-name">machida<\/span>/)
})

test('speak block without @ shows the default avatar without a link', () => {
  const html = render(speak, ':::speak username\n## 名前のみver\n:::')
  assert.match(html, /<div class="speak">/)
  assert.doesNotMatch(html, /href="\/users\/username"/)
  assert.match(html, /<img src="\/images\/users\/avatars\/default.png" alt="username" title="username"/)
})

test('speak block escapes HTML in the speaker name', () => {
  const html = render(speak, ':::speak <script>alert(1)</script>\n本文\n:::')
  assert.doesNotMatch(html, /<script>/)
})

test('figure block wraps the image and turns the rest into a caption', () => {
  const html = render(figure, ':::figure\n<a href="https://example.com/image.jpg"><img src="https://example.com/image.jpg"></a>\nキャプション本文\n:::\n')
  assert.match(html, /^<figure>/)
  assert.match(html, /<figcaption>キャプション本文<\/figcaption>/)
  assert.doesNotMatch(html, /<p>/)
})

test('external link opens on another tab', () => {
  const html = render(externalLink, 'http://www.google.co.jp')
  assert.equal(anchorTag(html, 'http://www.google.co.jp'), '<a href="http://www.google.co.jp" target="_blank" rel="noopener">http://www.google.co.jp</a>')
})

test('internal, relative and anchor links open on the same tab', () => {
  for (const [text, label, href] of [
    [origin, origin, origin],
    [`${origin}/reports`, `${origin}/reports`, `${origin}/reports`],
    ['[relative_link](/reports)', 'relative_link', '/reports'],
    ['[anchor_link](#anchortext)', 'anchor_link', '#anchortext']
  ]) {
    assert.equal(anchorTag(render(externalLink, text), label), `<a href="${href}">${label}</a>`)
  }
})
