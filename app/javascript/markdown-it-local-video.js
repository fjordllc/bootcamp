export default (md) => {
  md.inline.ruler.before('emphasis', 'localVideo', (state) => {
    const start = state.pos
    if (state.src.slice(start, start + 7) !== '!video(') return false
    const end = state.src.indexOf(')', start)
    if (end === -1) return false
    const src = state.src.slice(start + 7, end)
    if (!src) return false

    const token = state.push('localVideo')
    token.attrs = [
      ['controls', ''],
      ['src', src]
    ]

    state.pos = end + 1
    return true
  })

  md.renderer.rules.localVideo = (tokens, idx) => {
    const attrs = tokens[idx].attrs
      .map((attr) => `${attr[0]}="${attr[1]}"`)
      .join(' ')
    return `<video ${attrs}></video>`
  }
}
