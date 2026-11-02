export default function markdownItWikiLink(md) {
  const link = md.inline.ruler.__rules__.find((rule) => rule.name === 'link').fn
  const image = md.inline.ruler.__rules__.find(
    (rule) => rule.name === 'image'
  ).fn
  const closingDelimiters = new WeakMap()
  let imageDepth = 0

  // Image alt text is parsed in a fresh inline state, without linkLevel.
  md.inline.ruler.at('image', (state, silent) => {
    imageDepth++
    try {
      return image(state, silent)
    } finally {
      imageDepth--
    }
  })

  md.inline.ruler.before('link', 'wiki_link', (state, silent) => {
    const start = state.pos
    // Let MarkdownIt's label scanner count brackets normally in silent mode.
    if (silent || state.linkLevel > 0 || imageDepth > 0) return false
    if (state.src.slice(start, start + 2) !== '[[') return false

    let cached = closingDelimiters.get(state)
    if (!cached || cached.max !== state.posMax) {
      // Cache the next unescaped closer for every suffix in one backward pass.
      // Newlines terminate a label, including when preceded by a backslash.
      const ends = new Int32Array(state.posMax + 2).fill(-1)
      for (let position = state.posMax - 2; position >= 0; position--) {
        const character = state.src[position]
        const next = state.src[position + 1]
        if (character === '\n' || character === '\r') continue
        if (character === '\\') {
          if (next !== '\n' && next !== '\r') {
            ends[position] = ends[position + 2]
          }
        } else if (character === ']' && next === ']') {
          ends[position] = position
        } else {
          ends[position] = ends[position + 1]
        }
      }
      cached = { max: state.posMax, ends }
      closingDelimiters.set(state, cached)
    }
    const end = cached.ends[start + 2]
    if (end === undefined || end < 0) return false

    // A valid ordinary link such as [[label]](/url) takes precedence.
    const ordinaryLink = link(state, true)
    state.pos = start
    if (ordinaryLink) return false

    const label = state.src.slice(start + 2, end)
    const reference = md.utils.normalizeReference(label)
    if (Object.hasOwn(state.env.references ?? {}, reference)) return false
    // Browsers normalize even percent-encoded dot segments outside /pages/.
    if (!label.trim() || label === '.' || label === '..') return false
    // In Unicode mode this matches lone surrogates, but accepts valid pairs.
    if (/[\uD800-\uDFFF]/u.test(label)) return false

    const open = state.push('link_open', 'a', 1)
    open.attrSet('href', `/pages/${encodeURIComponent(label)}`)
    // Core emoji replacement skips automatic link labels.
    open.info = 'auto'
    state.push('text', '', 0).content = label
    state.push('link_close', 'a', -1).info = 'auto'
    state.pos = end + 2
    return true
  })
}
