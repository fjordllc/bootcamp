import * as plugin from 'markdown-it-anchor'

const options = {
  permalink: plugin.permalink.linkInsideHeader({
    symbol: '<i class="fas fa-link"></i>',
    placement: 'before',
    ariaHidden: true
  })
}

export default function (md) {
  return plugin(md, options)
}
