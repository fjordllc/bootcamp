import Prism from 'prismjs'

globalThis.Prism = Prism

await import('prismjs/components/prism-clike')
await import('prismjs/components/prism-css')
await import('prismjs/components/prism-css-extras')
await import('prismjs/components/prism-bash')
await import('prismjs/components/prism-ruby')
await import('prismjs/components/prism-markup-templating')
await import('prismjs/components/prism-erb')
await import('prismjs/components/prism-haml')
await import('prismjs/components/prism-javascript')
await import('prismjs/components/prism-sass')
await import('prismjs/components/prism-scss')
await import('prismjs/components/prism-pug')
await import('prismjs/components/prism-markdown')
await import('prismjs/components/prism-go')
await import('prismjs/components/prism-http')
await import('prismjs/components/prism-json')
await import('prismjs/components/prism-nginx')
await import('prismjs/components/prism-sql')
await import('prismjs/components/prism-yaml')
await import('prismjs/components/prism-shell-session')
await import('prismjs/components/prism-typescript')
await import('prismjs/components/prism-jsx')
await import('prismjs/components/prism-tsx')

export default Prism
