import assert from 'node:assert/strict'
import { readFile } from 'node:fs/promises'
import test from 'node:test'

// Use the same self-contained parser pinned in config/importmap.rb.
const parserSource = await readFile(new URL('../../vendor/javascript/markdown-it.js', import.meta.url), 'utf8')
const { default: MarkdownIt } = await import(`data:text/javascript;base64,${Buffer.from(parserSource).toString('base64')}`)
const pluginSource = await readFile(new URL('../../app/javascript/markdown-it-wiki-link.js', import.meta.url), 'utf8')
const { default: wikiLink } = await import(`data:text/javascript;base64,${Buffer.from(pluginSource).toString('base64')}`)
const parser = () => new MarkdownIt({ html: true, breaks: true, linkify: true }).use(wikiLink)

test('renders multiple wiki links surrounded by ordinary Markdown', () => {
  assert.equal(parser().renderInline('Before [[AAA]] and [[glossary]] **after**.'),
    'Before <a href="/pages/AAA">AAA</a> and <a href="/pages/glossary">glossary</a> <strong>after</strong>.')
})

test('preserves labels and encodes each destination as one path segment', () => {
  const md = parser()
  for (const label of ['日本語', 'two words', ' leading and trailing ', 'a/b?c#d%&"<>', 'https://evil.example/path', '*bold* @komagata :smile:']) {
    assert.equal(md.renderInline(`[[${label}]]`),
      `<a href="/pages/${md.utils.escapeHtml(encodeURIComponent(label))}">${md.utils.escapeHtml(label)}</a>`)
  }
})

test('HTML in labels is text, never markup or attributes', () => {
  assert.equal(parser().renderInline('[[<img src=x onerror="alert(1)">]]'),
    '<a href="/pages/%3Cimg%20src%3Dx%20onerror%3D%22alert(1)%22%3E">&lt;img src=x onerror=&quot;alert(1)&quot;&gt;</a>')
})

test('wiki labels are not recursively parsed or linkified', () => {
  assert.equal(parser().renderInline('[[*bold* `code` https://example.com &amp;]]'),
    '<a href="/pages/*bold*%20%60code%60%20https%3A%2F%2Fexample.com%20%26amp%3B">*bold* `code` https://example.com &amp;amp;</a>')
})

test('dot segments stay literal instead of navigating outside pages', () => {
  assert.equal(parser().renderInline('[[.]] [[..]]'), '[[.]] [[..]]')
})

test('empty, whitespace-only, multiline and unclosed syntax stays literal', () => {
  const baseline = new MarkdownIt({ html: true, breaks: true, linkify: true })
  for (const source of ['[[]]', '[[ ]]', '[[\t]]', '[[AAA\nBBB]]', '[[AAA\\\nBBB]]', '[[AAA', '[[AAA]', '[[AAA\\]]']) {
    assert.equal(parser().render(source), baseline.render(source), source)
  }
})

test('escaped delimiters and code retain normal Markdown behavior', () => {
  const baseline = new MarkdownIt({ html: true, breaks: true, linkify: true })
  for (const source of [String.raw`\[[AAA]]`, String.raw`[\[AAA]]`, String.raw`[[AAA\]\]]`, '`[[AAA]]`', '```\n[[AAA]]\n```', '    [[AAA]]']) {
    assert.equal(parser().render(source), baseline.render(source), source)
  }
})

test('ordinary links, reference links, images and HTML anchors remain valid', () => {
  const baseline = new MarkdownIt({ html: true, breaks: true, linkify: true })
  for (const source of [
    '[label [[AAA]]](/other)', '[[AAA]](/other)',
    '[label [[AAA]]][ref]\n\n[ref]: /other',
    '![label [[AAA]]](/image.png)', '![[AAA]](/image.png)',
    '<a href="/other">[[AAA]]</a>', '[ordinary](/other) ![ordinary](/image.png)'
  ]) {
    assert.equal(parser().render(source), baseline.render(source), source)
  }
})

test('defined shortcut and collapsed references keep precedence over wiki links', () => {
  const baseline = new MarkdownIt({ html: true, breaks: true, linkify: true })
  for (const source of ['[[AAA]]\n\n[AAA]: /x', '[[AAA]][]\n\n[AAA]: /x']) {
    assert.equal(parser().render(source), baseline.render(source), source)
  }
})

test('a valid link following malformed syntax is still parsed', () => {
  assert.equal(parser().renderInline('[[]] then [[AAA]]'), '[[]] then <a href="/pages/AAA">AAA</a>')
})

test('silent checks and rejected input preserve parser position and tokens', () => {
  const md = parser()
  const rule = md.inline.ruler.__rules__.find((rule) => rule.name === 'wiki_link').fn
  const state = new md.inline.State('before [[AAA]] after', md, {}, [])
  state.pos = 7
  const max = state.posMax
  assert.equal(rule(state, true), false)
  assert.equal(state.pos, 7)
  assert.equal(state.posMax, max)
  assert.deepEqual(state.tokens, [])
  assert.equal(rule(state, false), true)
  assert.equal(state.pos, 14)
  assert.equal(state.posMax, max)
  assert.deepEqual(state.tokens.map((token) => token.type), ['link_open', 'text', 'link_close'])

  const malformed = new md.inline.State('[[unclosed', md, {}, [])
  assert.equal(rule(malformed, false), false)
  assert.equal(malformed.pos, 0)
  assert.deepEqual(malformed.tokens, [])
})

test('unclosed brackets have bounded scanning and skip ordinary-link probes', () => {
  for (const size of [512, 1024]) {
    const md = new MarkdownIt()
    const link = md.inline.ruler.__rules__.find((rule) => rule.name === 'link').fn
    let probes = 0
    md.inline.ruler.at('link', (state, silent) => {
      probes++
      return link(state, silent)
    })
    md.use(wikiLink)
    const source = '['.repeat(size)
    const state = new md.inline.State(source, md, {}, [])
    let reads = 0
    // Count actual source characters inspected, independently of machine speed.
    state.src = new Proxy(new String(source), {
      get(target, property) {
        if (/^\d+$/.test(String(property))) reads++
        if (property === 'slice') return (start, end) => {
          const result = source.slice(start, end)
          reads += result.length
          return result
        }
        if (property === 'charCodeAt') return (position) => {
          reads++
          return source.charCodeAt(position)
        }
        const value = Reflect.get(target, property)
        return typeof value === 'function' ? value.bind(target) : value
      }
    })
    const rule = md.inline.ruler.__rules__.find((rule) => rule.name === 'wiki_link').fn
    for (let position = 0; position < source.length - 1; position++) {
      state.pos = position
      assert.equal(rule(state, false), false)
      assert.equal(state.pos, position)
    }
    assert.ok(reads <= source.length * 8, `${size} brackets required ${reads} character reads`)
    assert.equal(probes, 0)
    assert.deepEqual(state.tokens, [])
  }
})

test('cached scanning preserves escaped closers and stops at newlines', () => {
  assert.equal(parser().renderInline(String.raw`[[one\]]two]] [[three]]`),
    '<a href="/pages/one%5C%5D%5Dtwo">one\\]]two</a> <a href="/pages/three">three</a>')
  const baseline = new MarkdownIt({ html: true, breaks: true, linkify: true })
  for (const source of ['['.repeat(128) + '\n[[AAA]]', '['.repeat(128) + '\r[[AAA]]']) {
    assert.equal(parser().renderInline(source), baseline.renderInline(source.replace('[[AAA]]', 'WIKI')).replace('WIKI', '<a href="/pages/AAA">AAA</a>'))
  }
})

test('lone UTF-16 surrogates stay baseline literal without tokens or exceptions', () => {
  const baseline = new MarkdownIt({ html: true, breaks: true, linkify: true })
  for (const label of ['\uD800', '\uDC00', 'before\uD800after', '\uDC00\uD800']) {
    const source = `[[${label}]]`
    const md = parser()
    assert.equal(md.renderInline(source), baseline.renderInline(source))
    const rule = md.inline.ruler.__rules__.find((rule) => rule.name === 'wiki_link').fn
    const state = new md.inline.State(source, md, {}, [])
    assert.equal(rule(state, false), false)
    assert.equal(state.pos, 0)
    assert.deepEqual(state.tokens, [])
  }
  assert.equal(parser().renderInline('[[😀]]'), '<a href="/pages/%F0%9F%98%80">😀</a>')
})
