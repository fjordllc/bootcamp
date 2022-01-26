import plugin from 'markdown-it-anchor'
import slugify from '@sindresorhus/slugify'

const options = {
  permalink: plugin.permalink.linkInsideHeader({
    symbol: '<i class="fas fa-link"></i>',
    placement: 'before',
    ariaHidden: true
  }),
  slugify: (s) => slugify(s)
}

export default function (md) {
  return plugin(md, options)
}
